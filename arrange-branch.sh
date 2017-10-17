git checkout master
# move personal config to the last one
git rebase -i HEAD~5
git checkout stable
git merge master
# delete personal config
git rebase -i HEAD~5
# done
git log --graph --all
