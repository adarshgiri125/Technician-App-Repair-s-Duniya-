// ignore_for_file: no_leading_underscores_for_local_identifiers, prefer_final_fields, avoid_init_to_null, unused_local_variable, unused_field, prefer_const_declarations

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:technician_app/core/app_export.dart';
import 'package:technician_app/presentation/id_verification_screen/id_verification_screen.dart';
import 'package:technician_app/widgets/custom_elevated_button.dart';
import 'package:technician_app/widgets/custom_outlined_button.dart';
import 'package:technician_app/widgets/custom_text_form_field.dart';
import 'package:uuid/uuid.dart';
import 'package:location/location.dart' as loc;
import 'package:permission_handler/permission_handler.dart' as handler;
import 'package:http/http.dart' as http;

class ConfirmLocationScreen extends StatefulWidget {
  const ConfirmLocationScreen({super.key});

  @override
  State<ConfirmLocationScreen> createState() => _ConfirmLocationScreenState();
}

class _ConfirmLocationScreenState extends State<ConfirmLocationScreen> {
  Completer<GoogleMapController> _mapController =
      Completer<GoogleMapController>();
  final List<String> codes = [
    '516001',
    '516002',
    '516003',
    '516004',
    '560076',
    '560102',
    '560068',
  ];
  LatLng _currentPosition = LatLng(14.4673, 78.8242);
  String _postalCode = '';
  String _currentAddress = '';
  TextEditingController _controller = TextEditingController();
  var uuid = const Uuid();
  String? sessionToken = '1234';
  List<dynamic> _placesList = [];
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  loc.PermissionStatus _permission = loc.PermissionStatus.denied;

  Future<void> getUserLocation() async {
    Position _position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemarks =
        await placemarkFromCoordinates(_position.latitude, _position.longitude);
    Placemark place = placemarks[0];

    setState(() {
      _currentPosition = LatLng(_position.latitude, _position.longitude);
      _currentAddress =
          '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';
      _postalCode = place.postalCode!;
    });

    final GoogleMapController controller = await _mapController.future;
    controller.animateCamera(CameraUpdate.newLatLngZoom(
      LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
      13,
    ));
  }

  Future<void> checkPermissions() async {
    var status = await Permission.location.status;

    if (status == PermissionStatus.denied) {
      // Location permission is denied, show a dialog with an option to open app settings
      showLocationPermissionDialog(context);
    } else if (status == PermissionStatus.granted) {
      // User has granted location permission, proceed to get the current location
      await getUserLocation();
      return;
    } else {
      // User has not yet been asked for permission, request it
      await Permission.location.request();
      getUserLocation();
    }
  }

  void showLocationPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Location Permission"),
          content: Text("Turn on the location permission"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text(
                "Cancel",
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                openAppSettings(); // Open app settings
                Navigator.pop(context); // Close the dialog
              },
              child: Text(
                "Open Settings",
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void onChange() {
    if (sessionToken == null) {
      setState(() {
        sessionToken = uuid.v4();
      });
    }

    try {
      getSuggestion(_controller.text);
    } catch (e) {
      log(e.toString());
    }
  }

  void getSuggestion(String s) async {
    String requestUrl =
        '$GOOGLE_MAPS_PLACES_API?input=$s&key=$GOOGLE_MAPS_API_KEY&sessiontoken=$sessionToken';
    var response = await http.get(Uri.parse(requestUrl));

    if (response.statusCode == 200) {
      setState(() {
        _placesList = jsonDecode(response.body.toString())['predictions'];
        log(_placesList.toString());
      });
    } else {
      throw Exception('Failed........');
    }
  }

  Future<void> uploadLocation() async {
    try {
      await _firestore
          .collection('technicians')
          .doc(_user!.uid)
          .collection('location')
          .doc('homeLocation')
          .set({
        'latitude': _currentPosition!.latitude,
        'longitude': _currentPosition!.longitude
      }, SetOptions(merge: true));

      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const IdVerificationScreen()));
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> _updateMarkerPosition(LatLng newPosition) async {
    try {
      setState(() {
        _currentPosition = newPosition;
      });

      List<Placemark> placemarks = await placemarkFromCoordinates(
        newPosition.latitude,
        newPosition.longitude,
      );

      Placemark place = placemarks[0];

      final GoogleMapController controller = await _mapController.future;

      setState(() {
        _currentAddress =
            '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';
        _postalCode = place.postalCode!;
      });
    } catch (e) {
      log('Error in updateposition: $e');
    }
  }

  Future<void> _updateCameraPosition(GoogleMapController controller) async {
    LatLngBounds visibleRegion = await controller.getVisibleRegion();
    LatLng center = LatLng(
      (visibleRegion.southwest.latitude + visibleRegion.northeast.latitude) / 2,
      (visibleRegion.southwest.longitude + visibleRegion.northeast.longitude) /
          2,
    );

    setState(() {
      _currentPosition = center;
    });
    await _updateMarkerPosition(center);
  }

  @override
  void initState() {
    super.initState();
    _auth.authStateChanges().listen((User? user) {
      setState(() {
        _user = user;
      });
    });
    checkPermissions();
    _controller.addListener(() {
      onChange();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: _controller.text.isEmpty
            ? Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildPickALocationFrame(context),
                  SizedBox(
                    height: 455.h,
                    width: double.maxFinite,
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: _currentPosition,
                            zoom: 13,
                          ),
                          zoomControlsEnabled: false,
                          onMapCreated: (GoogleMapController controller) {
                            _mapController.complete(controller);
                            _updateCameraPosition(controller);
                          },
                          markers: {
                            Marker(
                              markerId: const MarkerId('currentLocation'),
                              icon: BitmapDescriptor.defaultMarker,
                              position: _currentPosition!,
                              draggable: true,
                              onDragEnd: (LatLng newPosition) {
                                _updateMarkerPosition(newPosition);
                              },
                            )
                          },
                          onCameraMove: (CameraPosition position) {
                            setState(() {
                              _currentPosition = position.target;
                            });
                          },
                          onCameraIdle: () async {
                            final GoogleMapController controller =
                                await _mapController.future;
                            _updateCameraPosition(controller);
                          },
                          onTap: (LatLng tappedPoint) {
                            _updateMarkerPosition(tappedPoint);
                          },
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: EdgeInsets.only(
                                left: 76.h, right: 76.h, bottom: 9.v),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildUseMyCurrentLocation(context),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildConfirmLocationFrame(context)
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildPickALocationFrame(context),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _placesList.length,
                      itemBuilder: (context, index) => ListTile(
                        onTap: () async {
                          List<Location> l = await locationFromAddress(
                              _placesList[index]['description']);
                          LatLng latLng =
                              LatLng(l.last.latitude, l.last.longitude);
                          List<Placemark> places =
                              await placemarkFromCoordinates(
                                  latLng.latitude, latLng.longitude);
                          Placemark place = places[0];

                          final GoogleMapController controller =
                              await _mapController.future;
                          double zoomLevel = 13;
                          controller.animateCamera(CameraUpdate.newLatLngZoom(
                            LatLng(latLng.latitude, latLng.longitude),
                            zoomLevel,
                          ));

                          setState(() {
                            _currentPosition = latLng;
                            _currentAddress =
                                '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';
                            _postalCode = place.postalCode!;
                          });
                          _controller.clear();
                        },
                        title: Text(
                          _placesList[index]['description'],
                          style: CustomTextStyles.bodySmallGray800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  /// Section Widget
  Widget _buildUseMyCurrentLocation(BuildContext context) {
    return CustomOutlinedButton(
        text: "Use my Current Location",
        leftIcon: Container(
          margin: EdgeInsets.only(right: 8.h),
          child: CustomImageView(
            imagePath: ImageConstant.imgVector,
            height: 22.v,
            width: 20.h,
          ),
        ),
        textStyle: TextStyle(color: Colors.black, fontSize: 17.v),
        onPressed: () async {
          await checkPermissions();
          getUserLocation();
        });
  }

  Widget _buildPickALocationFrame(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 24.h,
        vertical: 11.v,
      ),
      decoration: AppDecoration.gradientPrimaryToGray,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(height: 17.v),
          Text(
            "Pick a location",
            style: CustomTextStyles.headlineSmallOnError,
          ),
          SizedBox(height: 9.v),
          CustomTextFormField(
            onChanged: (value) {},
            controller: _controller,
            hintText: "Search Your Location",
            textInputAction: TextInputAction.done,
            prefix: Container(
              margin: EdgeInsets.fromLTRB(19.h, 9.v, 8.h, 9.v),
              child: CustomImageView(
                imagePath: ImageConstant.imgVector22x20,
                height: 22.v,
                width: 20.h,
              ),
            ),
            prefixConstraints: BoxConstraints(
              maxHeight: 40.v,
            ),
            suffix: Container(
              margin: EdgeInsets.fromLTRB(30.h, 6.v, 12.h, 6.v),
              child: CustomImageView(
                imagePath: ImageConstant.imgDownChevron,
                height: 28.v,
                width: 24.h,
              ),
            ),
            suffixConstraints: BoxConstraints(
              maxHeight: 40.v,
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 11.v),
          ),
        ],
      ),
    );
  }

  /// Section Widget
  Widget _buildConfirmLocationFrame(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 23.h,
        vertical: 20.v,
      ),
      decoration: AppDecoration.gradientOnErrorToGray,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomImageView(
            imagePath: ImageConstant.imgImage72,
            height: 66.adaptSize,
            width: 66.adaptSize,
          ),
          SizedBox(height: 3.v),
          Text(
            "Confirm your location",
            style: theme.textTheme.headlineSmall,
          ),
          SizedBox(height: 18.v),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 5.h),
            padding: EdgeInsets.symmetric(
              horizontal: 31.h,
              vertical: 14.v,
            ),
            decoration: AppDecoration.fillGray.copyWith(
              borderRadius: BorderRadiusStyle.roundedBorder15,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomImageView(
                  imagePath: ImageConstant.imgVector22x20,
                  height: 24.v,
                  width: 22.h,
                  margin: EdgeInsets.only(
                    top: 1.v,
                    bottom: 9.v,
                  ),
                ),
                Expanded(
                  child: Container(
                    width: 261.h,
                    margin: EdgeInsets.only(
                      left: 19.h,
                      top: 1.v,
                      right: 6.h,
                    ),
                    child: Text(
                      _currentAddress,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: CustomTextStyles.bodySmallGray800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.v),
          CustomElevatedButton(
            onPressed: () {
              if (codes.contains(_postalCode) == true) {
                uploadLocation();
              } else {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    content: Text('Invalid pincode....',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: MediaQuery.of(context).size.width * 0.1)),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'OK',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: mediaQueryData.size.width * 0.05),
                        ),
                      )
                    ],
                  ),
                );
              }
            },
            text: "Yes, that’s my location",
            buttonStyle: CustomButtonStyles.none,
            decoration: CustomButtonStyles.gradientPrimaryToGrayDecoration,
          ),
        ],
      ),
    );
  }
}
