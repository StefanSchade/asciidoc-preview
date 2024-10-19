#!/bin/bash
git fetch

for remote in $(git branch -r | grep -v '/HEAD'); do
    git checkout --track "${remote#origin/}" "$remote"
done

