function activate_github(reponame; tag = nothing, sha = nothing, force = false)
    # Make sure that our .projects environment is kosher. 
        projdir = joinpath(DEPOT_PATH[1], ".projects") # DEPOT_PATH[1] is our .julia 
        mkpath(projdir) 
    # For each case of inputs, end up with a concrete URL to download. 
    oursha = nothing 
    if sha != nothing 
        @assert length(sha) == 40 # Check that it's a valid SHA1 hash. 
        oursha = sha 
    elseif tag != nothing # Given a tag but no SHA. 
        # Get list of tags. 
        tagsurl = string("https://api.github.com/repos/$(reponame)/git/refs/tags")
        tagslist = HTTP.get(HTTP.URI(tagsurl), ["User-Agent" => "ubcecon"], "post body data")
        tagsdata = JSON.parse(String(tagslist.body))
        # Iterate through tags 
        for tag in tagsdata 
            if "refs/tags/$tag" != tag["ref"]
                continue 
            else 
                oursha = tag["object"]["sha"]
            end 
        end
        # Throw error otherwise. 
        @assert sha != nothing "Tag not found in list of tags."
    else # Download master.
        oursha = branch(reponame, "master").commit.sha
    end 
    # Turn this into a url. 
    oururl = "https://github.com/$(reponame)/archive/$(oursha).tar.gz"
    # Download that url to projects and unzip. 
    run(`curl -L $oururl -o $projdir/$oursha.tar.gz`)
    run(`tar -xvzf $projdir/$oursha.tar.gz -C $projdir`)
    run(`rm $projdir/$oursha.tar.gz`) # Remove all unzipped. 
end 