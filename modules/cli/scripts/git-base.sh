# Prints the commit HEAD builds on: its fork point from $1, else the newest commit HEAD
# shares with the nearest local or remote branch that does not contain HEAD.
# The branches containing HEAD never count, nor do their remotes, their <branch>-* copies
# and the backup/* branches.
if (($#)); then
  git merge-base --fork-point "$1" HEAD || git merge-base "$1" HEAD
  exit
fi

excludes=(--exclude='refs/heads/backup/*')
while read -r branch; do
  excludes+=(--exclude="refs/heads/$branch-*" --exclude="refs/remotes/*/$branch" --exclude="refs/remotes/*/$branch-*")
done < <(git for-each-ref --contains HEAD --format='%(refname:lstrip=2)' refs/heads)
mapfile -t others < <(git for-each-ref --no-contains HEAD "${excludes[@]}" --format='%(refname)' refs/heads refs/remotes)

oldest=$(git rev-list --first-parent HEAD --not "${others[@]}" | tail -n1)
if [ -n "$oldest" ]; then
  git rev-parse "$oldest^"
else
  git rev-parse HEAD
fi
