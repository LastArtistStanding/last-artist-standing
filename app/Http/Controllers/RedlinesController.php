<?php

namespace App\Http\Controllers;

use App\Redline;

use Illuminate\Http\Request;
use Intervention\Image\Exception\NotReadableException;
use Intervention\Image\Facades\Image;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;
use Exception;
use Illuminate\Support\Facades\File;

class RedlinesController extends Controller
{
    public function store($submission_id, Request $request) {
        $user =  Auth::user();

        $validator = Validator::make($request->all(), [
            'comment' => 'required|string|max:5000',
            'image_link' => 'sometimes|max:255'
        ]);

        if ($validator->fails()) {
            return response()->json(['error' => collect($validator->errors())->flatten()], 422);
        }

        if ($request->has('image_link')) {
            try {
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

            try {
                $image->fit(300, 300)->encode('jpg', 50);
            } catch(Exception $e) {
                return response()->json(['error' => ['Failed to thumbnail image.']], 422);
            }

            $random = rand(1000,9999);

            $thumbnailname = date("Y-m-d") . '_' . $random. '.jpg';
            $thumbnailpath = 'upload/' . $user->id . '/redline/';

            $redline = new Redline([
                'imagePath' => $request->image_link,
                'comment' => $request->comment
            ]);

            if (!File::exists($thumbnailpath)) {
                if(!File::makeDirectory($thumbnailpath, 0755, true)) {
                    return response()->json(['error' => ['No file permissions on system.']], 500);
                }
            }

            if ($image->save($thumbnailpath . $thumbnailname)) {
                $redline->thumbnailPath = $thumbnailpath . $thumbnailname;
            }
        } else {
            $redline = new Redline([
                'imagePath' => 'resources/unavailable.jpg',
                'comment' => $request->comment
            ]);

            $redline->thumbnailPath = 'resources/unavailable_thumbnail.jpg';
        }

        $redline->submission_id = $submission_id;
        $redline->user_id = $user->id;

        $redline->save();
        $redline->user;
        $redline->comment = preg_replace('/(&nbsp;(<br\s*\/?>\s*)|(<br\s*\/?>\s*))+/im', "<br /><br />\n", nl2br($redline->comment));
        return $redline;
    }

    public function showMine() {
        $user = Auth::user();
        return Redline::select('redlines.*')
            ->join('submissions', 'submissions.id', '=', 'redlines.submission_id')
            ->whereRaw('submissions.user_id = ' . $user->id)
            ->with('submission', 'user')
            ->orderBy('created_at', 'DESC')
            ->get();
    }

    public function update($submission_id) {
        // TODO
    }

    public function thumbnail($id) {
        $redline = Redline::where('id', '=', $id)->firstOrFail();
        $path = str_replace('\\', '/', public_path()) . '/' . $redline->thumbnailPath;
        try {
            return Image::make($path)->response();
        } catch(NotReadableException $e) {
            return Image::make('resources/unavailable_thumbnail.jpg')->response();
        }
    }
}
