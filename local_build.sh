#dart run change_app_package_name:main "com.saiful.salesman"
#dart run rename_app:main all="Salesman"
#dart run flutter_launcher_icons:main

flutter clean
flutter pub get
flutter build apk --release

# copy the apk to ~/Desktop
# delete old apk if exists
if [ -f ~/Desktop/salesman.apk ]; then
  rm ~/Desktop/salesman.apk
fi

cp build/app/outputs/flutter-apk/app-release.apk ~/Desktop/salesman.apk