module PagesHelper
    
    def dateToString(date)
        if date.nil?
            "None"
        else
            date.strftime("%D")
        end
    end
    
    def postfrequencyToString(postfrequency)
        case postfrequency
        when -1
            "Custom"
        when 1
            "Daily"
        when 2
            "Every Other Day"
        when 7
            "Weekly"
        when 0
            "None"
        else
            "Every #{postfrequency} Days"
        end
    end
    
    def getCurrentDateTime
        Time.now
    end
    
end
