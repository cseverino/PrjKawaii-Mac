cd "$( dirname "$0" )"
xcodebuild
cd build/Release
<<<<<<< HEAD
zip -vr gbb-osx.zip GelbooruViewer.app
../Sparkle\ 1.5b6/Extras/Signing\ Tools/sign_update.rb gbb-osx.zip ../Sparkle\ 1.5b6/Extras/Signing\ Tools/dsa_priv.pem > sign.txt
=======
zip -vr gbb-osx.zip GBBrowser.app
/Users/tigra/Desktop/Coding/Sparkle\ 1.5b6/Extras/Signing\ Tools/sign_update.rb gbb-osx.zip /Users/tigra/Desktop/Coding/Sparkle\ 1.5b6/Extras/Signing\ Tools/dsa_priv.pem > sign.txt
>>>>>>> 1.96
ls -l gbb-osx.zip >> sign.txt
rm -r *.app
rm *.dSYM
open .
