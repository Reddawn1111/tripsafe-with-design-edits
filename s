warning: in the working copy of 'SIHprojectf01/lib/widgets/city_pulse_card.dart', LF will be replaced by CRLF the next time Git touches it
[1mdiff --git a/SIHprojectf01/lib/screens/discovery/place_detail_sheet.dart b/SIHprojectf01/lib/screens/discovery/place_detail_sheet.dart[m
[1mindex 81bcf05..96a52eb 100644[m
[1m--- a/SIHprojectf01/lib/screens/discovery/place_detail_sheet.dart[m
[1m+++ b/SIHprojectf01/lib/screens/discovery/place_detail_sheet.dart[m
[36m@@ -335,9 +335,12 @@[m [mclass _PlaceDetailSheetState extends State<PlaceDetailSheet> {[m
         children: [[m
           Row([m
             children: [[m
[31m-              Text([m
[31m-                '📊 Travel Pulse',[m
[31m-                style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold),[m
[32m+[m[32m              Flexible([m
[32m+[m[32m                child: Text([m
[32m+[m[32m                  '📊 Travel Pulse',[m
[32m+[m[32m                  style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold),[m
[32m+[m[32m                  overflow: TextOverflow.ellipsis,[m
[32m+[m[32m                ),[m
               ),[m
               if (stats?.isDemoData == true) ...[[m
                 const SizedBox(width: 6),[m
[1mdiff --git a/SIHprojectf01/lib/widgets/city_pulse_card.dart b/SIHprojectf01/lib/widgets/city_pulse_card.dart[m
[1mindex 55e97c6..b91a117 100644[m
[1m--- a/SIHprojectf01/lib/widgets/city_pulse_card.dart[m
[1m+++ b/SIHprojectf01/lib/widgets/city_pulse_card.dart[m
[36m@@ -32,9 +32,12 @@[m [mclass CityPulseCard extends StatelessWidget {[m
                 children: [[m
                   Row([m
                     children: [[m
[31m-                      Text([m
[31m-                        "What's happening around you",[m
[31m-                        style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),[m
[32m+[m[32m                      Flexible([m
[32m+[m[32m                        child: Text([m
[32m+[m[32m                          "What's happening around you",[m
[32m+[m[32m                          style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),[m
[32m+[m[32m                          overflow: TextOverflow.ellipsis,[m
[32m+[m[32m                        ),[m
                       ),[m
                       if (data?.isDemoData == true) ...[[m
                         const SizedBox(width: 6),[m
