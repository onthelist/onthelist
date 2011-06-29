cd ../../
rm -r ~/tmp
mkdir ~/tmp
cp -R site/public/* ~/tmp
git checkout gh-pages
mv ~/tmp/* .
git add .
git commit -m "Update pages to match public dir of master"
git push origin gh-pages

git checkout master

