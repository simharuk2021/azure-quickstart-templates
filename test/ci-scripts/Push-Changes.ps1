param(
    [string] $SampleFolder = $ENV:SAMPLE_FOLDER, # this is the path to the sample
    [string] $SampleName = $ENV:SAMPLE_NAME # the name of the sample or folder path from the root of the repo e.g. "sample-type/sample-name"
)

$gitStatus = $(git status)
Write-Output "Found Git Status of: `n $gitStatus"

git diff

git config core.autocrlf
Write-Output "^^^^ autocrlf"
#git config --system core.autocrlf input
        
if($gitStatus -like "*Changes not staged for commit:*" -or 
   $gitStatus -like "*Untracked files:*"){
   
    Write-Output "found changes in $gitStatus"
            
    git config --worktree user.email "azure-quickstart-templates@noreply.github.com"
    git config --worktree user.name "Azure Quickstarts Pipeline"
    
    Write-Output "checkout branch..."
    git checkout "master"

    Write-Output "checking git status..."
    git status
        
    Write-Output "Committing changes..."

    # not sure we want to always add the PR# to the message but we're using it during testing so we can test multiple runs of the pipeline without another PR merge
    # also add the files that were committed to the msg
    $msg = " for ($SampleName) and PR (#$($ENV:GITHUB_PR_NUMBER))"
    if($gitStatus -like "*azuredeploy.json"){
        $msg = " azuredeploy.json $msg"
    }
    if($gitStatus -like "*readme.md*"){
        $msg = " README.md $msg"
    }
    $msg = "update $msg"

    git add -A -v # for when we add azuredeploy.json for main.bicep samples
    git commit -v -a -m $msg # "update README.md YAML header for ($SampleName) and PR (#$($ENV:GITHUB_PR_NUMBER))"

    Write-Output "Status after commit..."
    git status
    Write-Output "Pushing..."
    # this triggers the copy badges PR, which will fail every time (we shouldn't trigger it if at all possible) - or run them together
    git push origin "master" 
    Write-Output "Status after push..."
    git status

}
