// // lib/screens/developer_apps_page.dart

// // ignore_for_file: deprecated_member_use, duplicate_ignore

// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
// import 'dart:math';
// import 'dart:ui';

// import 'package:flutter/foundation.dart'; // For consolidateHttpClientResponseBytes
// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';

// /// Model class representing a store application.
// class StoreApp {
//   final String name;
//   final String iconUrl;
//   final String detailsUrl;
//   final String description;
//   final String genres; // iOS only
//   final String price; // iOS only

//   StoreApp({
//     required this.name,
//     required this.iconUrl,
//     required this.detailsUrl,
//     required this.description,
//     this.genres = '',
//     this.price = '',
//   });

//   /// Creates a [StoreApp] instance from JSON.
//   factory StoreApp.fromJson(Map<String, dynamic> json, String baseUrl) {
//     return StoreApp(
//       name: json['name'] as String,
//       iconUrl: '$baseUrl${json['icon'] as String}',
//       detailsUrl: json['detailsUrl'] as String,
//       description: (json['description'] as String?) ?? '',
//       genres: (json['genres'] as String?) ?? '',
//       price: (json['price'] as String?) ?? '',
//     );
//   }
// }

// /// Global in-memory cache for image futures.
// final Map<String, Future<File>> _imageCache = {};

// /// Retrieves a cached image or downloads and caches it if not available.
// Future<File> _getCachedImage(String url) {
//   if (_imageCache.containsKey(url)) {
//     return _imageCache[url]!;
//   } else {
//     final futureFile = _downloadAndCacheImage(url);
//     _imageCache[url] = futureFile;
//     return futureFile;
//   }
// }

// /// Downloads image bytes via [HttpClient] and saves them as a file.
// Future<File> _downloadAndCacheImage(String url) async {
//   // Use a simple filename based on the URL's hashCode.
//   final cacheDir = Directory.systemTemp;
//   final fileName = "cache_${url.hashCode}.img";
//   final file = File('${cacheDir.path}/$fileName');
//   if (await file.exists()) {
//     return file;
//   }
//   final httpClient = HttpClient();
//   try {
//     final request = await httpClient.getUrl(Uri.parse(url));
//     final response = await request.close();
//     if (response.statusCode != 200) {
//       throw Exception(
//         'Failed to load image (Status Code: ${response.statusCode})',
//       );
//     }
//     final bytes = await consolidateHttpClientResponseBytes(response);
//     await file.writeAsBytes(bytes);
//     return file;
//   } finally {
//     httpClient.close();
//   }
// }

// /// A widget that loads an image from cache (or downloads it) and displays it.
// class CachedImage extends StatelessWidget {
//   final String url;
//   final BoxFit fit;
//   final double? width;
//   final double? height;
//   final Color? errorColor;

//   const CachedImage({
//     super.key,
//     required this.url,
//     this.fit = BoxFit.cover,
//     this.width,
//     this.height,
//     this.errorColor,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<File>(
//       future: _getCachedImage(url),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.done) {
//           if (snapshot.hasError) {
//             return Container(
//               width: width,
//               height: height,
//               color: errorColor ?? Colors.grey,
//             );
//           }
//           return Image.file(
//             snapshot.data!,
//             fit: fit,
//             width: width,
//             height: height,
//           );
//         }
//         return Container(
//           width: width,
//           height: height,
//           color: Colors.grey.shade300,
//         );
//       },
//     );
//   }
// }

// /// DeveloperAppsPage displays a vertical list of featured apps.
// class DeveloperAppsPage extends StatefulWidget {
//   const DeveloperAppsPage({super.key});

//   @override
//   // ignore: library_private_types_in_public_api
//   _DeveloperAppsPageState createState() => _DeveloperAppsPageState();
// }

// class _DeveloperAppsPageState extends State<DeveloperAppsPage> {
//   static const String _baseUrl = 'https://pixoplayusa.com/developerapps/';
//   late Future<List<StoreApp>> _appsFuture;

//   @override
//   void initState() {
//     super.initState();
//     _loadApps();
//   }

//   void _loadApps() {
//     final url =
//         Platform.isIOS
//             ? '$_baseUrl/devapplist_ios.json'
//             : '$_baseUrl/devapplist_android.json';
//     _appsFuture = _fetchApps(url);
//   }

//   /// Fetches the JSON, caches it (if changed), and returns a random 40% subset of apps.
//   Future<List<StoreApp>> _fetchApps(String url) async {
//     final fileName =
//         Platform.isIOS ? "devapplist_ios.json" : "devapplist_android.json";
//     final cacheDir = Directory.systemTemp;
//     final file = File('${cacheDir.path}/$fileName');
//     String? cachedData;
//     if (await file.exists()) {
//       cachedData = await file.readAsString();
//     }
//     try {
//       final response = await HttpClient()
//           .getUrl(Uri.parse(url))
//           .then((r) => r.close());
//       if (response.statusCode != 200) {
//         throw Exception(
//           'Failed to load apps (Status Code: ${response.statusCode})',
//         );
//       }
//       final remoteData = await response.transform(utf8.decoder).join();
//       if (cachedData == null || cachedData != remoteData) {
//         // Update cache only if the remote JSON has changed.
//         await file.writeAsString(remoteData);
//         cachedData = remoteData;
//       }
//     } catch (e) {
//       if (cachedData == null) {
//         throw Exception('Failed to load apps and no cached data available: $e');
//       } else {
//         // Use the cached JSON if the remote fetch fails.
//       }
//     }
//     final List data = json.decode(cachedData) as List;
//     List<StoreApp> apps =
//         data
//             .map(
//               (raw) => StoreApp.fromJson(raw as Map<String, dynamic>, _baseUrl),
//             )
//             .toList();

//     // Randomly select 40% of the apps.
//     apps.shuffle(Random());
//     final int sampleCount = (apps.length * 0.4).ceil();
//     apps = apps.take(sampleCount).toList();
//     return apps;
//   }

//   Future<void> _refreshApps() async {
//     setState(_loadApps);
//     await _appsFuture;
//   }

//   Future<void> _openUrl(String url) async {
//     final uri = Uri.parse(url);
//     if (await canLaunchUrl(uri)) {
//       await launchUrl(uri, mode: LaunchMode.externalApplication);
//     }
//   }

//   /// Builds a single horizontal card with a blurred top half and white bottom half.
//   Widget _buildHorizontalAppCard(StoreApp app, bool isIOS, Color accent) {
//     const double cardHeight = 300;
//     return Card(
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(20),
//         // ignore: deprecated_member_use
//         side: BorderSide(color: accent.withOpacity(0.3), width: 1),
//       ),
//       elevation: 8,
//       shadowColor: Colors.black45,
//       margin: const EdgeInsets.symmetric(vertical: 8),
//       clipBehavior: Clip.hardEdge,
//       child: SizedBox(
//         height: cardHeight,
//         child: Stack(
//           children: [
//             // Top blurred background and white bottom half.
//             Column(
//               children: [
//                 Expanded(
//                   child: ImageFiltered(
//                     imageFilter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
//                     child: CachedImage(
//                       url: app.iconUrl,
//                       fit: BoxFit.cover,
//                       width: double.infinity,
//                       height: double.infinity,
//                       // ignore: deprecated_member_use
//                       errorColor: accent.withOpacity(0.9),
//                     ),
//                   ),
//                 ),
//                 Container(height: cardHeight / 1.5, color: Colors.white),
//               ],
//             ),
//             // Floating crisp icon.
//             Align(
//               alignment: const Alignment(0, -0.4),
//               child: Container(
//                 width: 100,
//                 height: 100,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(20),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black26,
//                       blurRadius: 8,
//                       offset: const Offset(0, 4),
//                     ),
//                   ],
//                 ),
//                 clipBehavior: Clip.hardEdge,
//                 child: CachedImage(url: app.iconUrl, fit: BoxFit.cover),
//               ),
//             ),
//             // App name.
//             Positioned(
//               bottom: 90,
//               left: 16,
//               right: 16,
//               child: Text(
//                 app.name,
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 22,
//                   color: Colors.black87,
//                 ),
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ),
//             // Gradient Install/GET button.
//             Positioned(
//               bottom: 21,
//               left: 0,
//               right: 0,
//               child: Center(
//                 child: Container(
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [Color(0xFFFF94C2), Color(0xFFFF5CA8)],
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                     ),
//                     borderRadius: BorderRadius.circular(30),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Color(0xFFFF5CA8).withOpacity(0.5),
//                         blurRadius: 10,
//                         offset: const Offset(0, 5),
//                       ),
//                     ],
//                   ),
//                   child: ElevatedButton(
//                     onPressed: () => _openUrl(app.detailsUrl),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.transparent,
//                       shadowColor: Colors.transparent,
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 80,
//                         vertical: 12,
//                       ),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(30),
//                       ),
//                     ),
//                     child: Text(
//                       isIOS
//                           ? (app.price.isNotEmpty ? app.price : 'GET')
//                           : 'Install',
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 16,
//                         letterSpacing: 1.2,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final bool isIOS = Platform.isIOS;
//     final String title = isIOS ? 'Featured iOS Apps' : 'Featured Android Apps';
//     final Color accent = Theme.of(context).colorScheme.primary;

//     return Scaffold(
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Color(0xFFFFD4E5), Color(0xFFFF94C2)],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//         ),
//         child: SafeArea(
//           child: Column(
//             children: [
//               // Header.
//               // Header with back button and title in one row.
//               Padding(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16.0,
//                   vertical: 16.0,
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     IconButton(
//                       icon: const Icon(Icons.arrow_back, color: Colors.white),
//                       onPressed: () => Navigator.pop(context),
//                     ),
//                     Text(
//                       title,
//                       style: const TextStyle(
//                         fontSize: 22,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
//                     const SizedBox(width: 48), // Placeholder to balance the row
//                   ],
//                 ),
//               ),
//               // List of horizontal cards.
//               Expanded(
//                 child: FutureBuilder<List<StoreApp>>(
//                   future: _appsFuture,
//                   builder: (context, snapshot) {
//                     if (snapshot.connectionState == ConnectionState.waiting) {
//                       return const Center(
//                         child: CircularProgressIndicator(
//                           valueColor: AlwaysStoppedAnimation<Color>(
//                             Colors.white,
//                           ),
//                         ),
//                       );
//                     }
//                     if (snapshot.hasError) {
//                       return Center(
//                         child: Text(
//                           'Error: ${snapshot.error}',
//                           style: const TextStyle(color: Colors.white),
//                         ),
//                       );
//                     }
//                     final apps = snapshot.data!;
//                     if (apps.isEmpty) {
//                       return RefreshIndicator(
//                         onRefresh: _refreshApps,
//                         child: ListView(
//                           physics: const AlwaysScrollableScrollPhysics(),
//                           children: const [
//                             SizedBox(height: 200),
//                             Center(
//                               child: Text(
//                                 'No apps found.\nPull down to retry.',
//                                 textAlign: TextAlign.center,
//                                 style: TextStyle(color: Colors.white),
//                               ),
//                             ),
//                           ],
//                         ),
//                       );
//                     }
//                     return RefreshIndicator(
//                       onRefresh: _refreshApps,
//                       child: ListView.builder(
//                         padding: const EdgeInsets.symmetric(vertical: 8),
//                         physics: const AlwaysScrollableScrollPhysics(),
//                         itemCount: apps.length,
//                         itemBuilder: (context, i) {
//                           return Padding(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 16,
//                               vertical: 8,
//                             ),
//                             child: _buildHorizontalAppCard(
//                               apps[i],
//                               isIOS,
//                               accent,
//                             ),
//                           );
//                         },
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
