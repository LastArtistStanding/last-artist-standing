module SubmissionsHelper
    
    def getNsfwString(level)
        case level
        when 1
            "Safe"
        when 2
            "Questionable"
        when 3
            "Explicit"
        else
            "???"
        end
    end
    
end
