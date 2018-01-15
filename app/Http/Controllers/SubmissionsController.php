<?php

namespace App\Http\Controllers;

use App\Challenge;
use App\ChallengeEntry;
use App\Streak;
use App\Submission;

use Carbon\Carbon;
use Illuminate\Contracts\Filesystem\FileNotFoundException;
use Illuminate\Database\Eloquent\ModelNotFoundException;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use Intervention\Image\Exception\NotReadableException;
use Intervention\Image\Facades\Image;
use Exception;
use Illuminate\Support\Facades\File;
use Tymon\JWTAuth\Facades\JWTAuth;

class SubmissionsController extends Controller
{
    use badges;

    public function index() {

        // Set any junk params to 0 and get todays submission.
        $offset = request()->offset;
        $offset = (int) $offset;
        if (!$offset || $offset < 0) {
            $offset = 0;
        }

        // Fetches all submissions from $offset days ago.
        return Submission::whereRaw('DATE(created_at) = DATE(\''. Carbon::now()->subDays($offset) .'\')')->with('user')->orderBy('created_at', 'desc')->get();
    }

    public function count() {
        $submissions = Submission::select(DB::raw('count(*) as count, created_at'))
            ->groupBy(DB::raw('DATE(created_at)'))
            ->limit(25)
            ->get();

        $today = Carbon::now();

        foreach($submissions as $submission) {
            $created = Carbon::parse($submission->created_at);
            $submission->created_at = $created->year . '-' . $created->month . '-' . $created->day;
            $submission->offset = $submission->created_at->diffInDays($today);
            //$submission->offset = $today;
        }

        return $submissions;
    }

    public function newest() {
        $submission = Submission::orderBy('created_at', 'desc')
            ->where('nsfw', '=', '0')
            ->limit(5)
            ->with('user')
            ->get();
        return $submission;
    }

    public function show($id) {
        $submission = Submission::where('id', $id)
            ->with(['user', 'challengeEntries.challenge'])
            ->firstOrFail();

        $value = request()->header('Authorization');
        if (isset($value) && $value && $submission->redline) {
            try {
                $user = JWTAuth::parseToken()->authenticate();
                if ($user) {
                    if ($user->id == $submission->user_id) {
                        $submission->redlines; // Get all redlines for my own submissions
                        foreach($submission->redlines as $redline) { // Bad but whatever.. Shouldn't be many entries
                            $redline->user;
                            $redline->comment = preg_replace('/(&nbsp;(<br\s*\/?>\s*)|(<br\s*\/?>\s*))+/im', "<br /><br />\n", nl2br($redline->comment));
                        }
                    } else {
                        $submission->redlines = $user->getMyRedlineInSubmission($submission->id);
                    }
                }
            } catch(Exception $e) { /* Ignore bad tokens */}
        }

        try {
            $submission->next = Submission::where('id', '>', $submission->id)->orderBy('id', 'ASC')->firstOrFail();
        } catch(ModelNotFoundException $e) {
            $submission->next = null;
        }

        try {
            $submission->previous = Submission::where('id', '<', $submission->id)->orderBy('id', 'DESC')->firstOrFail();
        } catch(ModelNotFoundException $e) {
            $submission->previous = null;
        }

        return $submission;
    }

    public function image($id) {
        $submission = Submission::where('id', $id)->firstOrFail();
        $path = str_replace('\\', '/', public_path()) . '/' . $submission->imagePath;
        try {
            $response = response()->make(File::get($path), 200);
            $response->header("Content-Type", File::type($path));
            return $response;
        } catch(FileNotFoundException $e) {
            return Image::make('resources/unavailable.jpg')->response();
        }
    }

    public function thumbnail($id) {
        $submission = Submission::where('id', $id)->firstOrFail();
        $path = str_replace('\\', '/', public_path()) . '/' . $submission->thumbnailPath;
        try {
            return Image::make($path)->response();
        } catch(NotReadableException $e) {
            return Image::make('resources/unavailable_thumbnail.jpg')->response();
        }
    }

    public function store(Request $request) {
        /*$throttler = Throttle::get($request, 1, 1); // Can submit every minute
        if(!$throttler->attempt($request)) {
           return response()->json(['error' => ['Please wait at least one minute between your submissions.']], 401);
        }*/

        // Validate and auth
        $user =  Auth::user();

        $validator = Validator::make($request->all(), [
            'title' => 'string|max:50',
            'description' => 'string|max:255',
            'image_link' => 'required|max:255|unique:submissions,imagePath,NULL,id,deleted_at,NULL',
            'challenges' => 'sometimes',
            'nsfw' => 'required|boolean',
            'redline' => 'required|boolean'
        ]);

        if ($validator->fails()) {
            return response()->json(['error' => collect($validator->errors())->flatten()], 422);
        }

        // Get image and check mime type
        try {
            //$image = Image::make($request->image);
            $image = Image::make($request->image_link);
        } catch(Exception $e) {
            return response()->json(['error' => ['Invalid image format, did you submit a direct image link? It\'s required. (Allowed formats: jpg, png, gif)']], 422);
        }

        switch($image->mime()) {
            case 'image/png': $imageExt = '.png'; break;
            case 'image/jpeg': $imageExt = '.jpg'; break;
            case 'image/gif': $imageExt = '.gif'; break;
            default: return response()->json(['error' => ['Invalid image format, did you submit a direct image link? It\'s required. (Allowed formats: jpg, png, gif)']], 422);
        }

        $image_pixels = ['height' => $image->height(), 'width' => $image->width()];

        // Create thumbnail
        try {
            $image->fit(300, 300)->encode('jpg', 50); // Transparent parts of gif turn blue, png turn black
        } catch(Exception $e) {
            return response()->json(['error' => ['Failed to thumbnail image.']], 422);
        }

        $random = rand(1000,9999);

        $thumbnailname = date("Y-m-d") . '_' . $random. '.jpg';
        $thumbnailpath = 'upload/' . $user->id . '/thumbnail/';

        $submission = new Submission($request->all());
        $submission->user_id = $user->id;

        if (!File::exists($thumbnailpath)) {
            if(!File::makeDirectory($thumbnailpath, 0755, true)) {
                return response()->json(['error' => ['No file permissions on system.']], 500);
            }
        }

        $submission->imagePath = $request->image_link;

        if ($image->save($thumbnailpath . $thumbnailname)) {
            $submission->thumbnailPath = $thumbnailpath . $thumbnailname;
        }

        $submission->nsfw = $request->nsfw ? 1 : 0;

        $submission->redline = $request->redline ? 1 : 0;

        $submission->save();
        $submission->user = $user;

        $streak = Streak::where('user_id', $user->id)->first();
        if (!$streak) {
            $streak = new Streak();
            $streak->store($submission);
        } else {
            $streak->updateStreak($submission);
        }

        if ($request->challenges) {
            foreach($request->challenges as $challengeIn) {
                $challenge = Challenge::where('id', $challengeIn)->first();
                if ($challenge->status != 'active') {
                    return response()->json(['error' => ['You can\'t enter an inactive challenge.']], 401);
                }

                $challengeEntry = new ChallengeEntry([
                    'challenge_id' => $challengeIn,
                    'submission_id' => $submission->id
                ]);
                $challengeEntry->user_id = $user->id;
                $challengeEntry->save();
            }
        }

        $this->onSubmissionBadges($user, $submission, $streak, $image_pixels);

        return $submission;
    }

    public function update($id) {
        $user =  Auth::user();

        $submission = Submission::where('id', $id)->firstOrFail();

        if ($submission->user_id != $user->id) {
            return response()->json(['error' => ['You can only edit your own submissions']], 401);
        }

        $validator = Validator::make(request()->all(), [
            'title' => 'string|max:50',
            'description' => 'string|max:255',
            'nsfw' => 'required|boolean',
            'redline' => 'required|boolean'
        ]);

        if ($validator->fails()) {
            return response()->json(['error' => collect($validator->errors())->flatten()], 422);
        }

        $result = $submission->update([
            'title' => request()->title,
            'description' => request()->description,
            'nsfw' => request()->nsfw,
            'redline' => request()->redline
        ]);

        if ($result) {
            $submission->user;
            $submission->challengeEntries;
            return $submission;
        } else {
            return response()->json(['error' => ['Failed to update submission.']], 500);
        }
    }

    public function delete($id) {
        $user =  Auth::user();

        $submission = Submission::where('id', $id)->firstOrFail();

        if ($submission->user_id != $user->id) {
            return response()->json(['error' => ['You can only edit your own submissions']], 401);
        }

        $result = $submission->delete();

        if ($result) {
            $challenge_entry = $submission->challengeEntries;
            foreach($challenge_entry as $entry) {
                $entry->delete();
            }
            return response()->json(['success' => true], 200);
        } else {
            return response()->json(['error' => ['Failed to delete submission.']], 500);
        }
    }
}
