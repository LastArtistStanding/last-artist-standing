module ChallengesHelper
    
    def getChallengeCreator(id)
        if id.present?
            User.find_by(id: id).name
        else
            "Site Challenge"
        end
    end
    
end
