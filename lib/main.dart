import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:simple_animated_icon/simple_animated_icon.dart';
import 'package:path/path.dart' as Path;
import 'package:file_selector/file_selector.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math';
import 'package:http/http.dart' as http;

late MethodChannel methodChannel;

late String directory;
int currentPageIndex = 0;
List<bool> playing = [false,
                      false,
                      false];
String setName = "";
late List<List<int>> patterns;
late List<List<int>> intensities;
late List<String> names;
late List<List<int>> myPatterns ;
late List<List<int>> myIntensities;
late List<String> myNames;
late List<File> hrs;

late File setFile;

late Random random;

double version = 1.0;

void main() async {
	WidgetsFlutterBinding.ensureInitialized();
  random = Random();
	directory = (await getApplicationDocumentsDirectory()).path;
	setFile = File(directory+'/'+'setRingtone'+'.hr.txt');
	methodChannel = MethodChannel('samples.flutter.dev/haptics');
	if(!(await methodChannel.invokeMethod<bool>('checkCallPermission'))!)
	{
		await (setFile.writeAsString("Beat 1"+'\n'+[175, 40, 10, 487, 10, 393, 8, 316, 8, 283, 8, 247, 8, 429, 8, 438, 8, 300, 8, 316, 10, 179, 10, 453, 8, 464, 8, 334, 8, 274, 8, 231, 8, 421, 8, 411, 8, 291, 8, 250].toString()
			+'\n'+[30, 0, 255, 0, 132, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 132, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0].toString()));
		methodChannel.invokeMethod('enableSilentMode');
	}
	await getHRs();
	setName = (await setFile.readAsString()).split('\n')[0];
	runApp(MainTheme());
}

class MainTheme extends StatefulWidget {
	const MainTheme({super.key});
	
	@override
	State<MainTheme> createState() => MainThemeState();
}

class MainThemeState extends State<MainTheme> {

	late final AppLifecycleListener _listener;

	@override
  void initState() {
    super.initState();
    _listener = AppLifecycleListener(
      //onInactive: (){Vibration.cancel();},
      onPause: (){Vibration.cancel();},
    );
  }

	@override
	Widget build(BuildContext context) {
		patterns = [
		  // Ring 1 (unchanged)
		  [20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 200, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 1000],
		  
		  // Ring 2 (unchanged)
		  [10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 1800],
		  
		  //Ring 3
		  [20,80,20,80,20,80,20,80,20,80,20,80,20,80,20,80,20,370],

		  // Heartbeat (unchanged)
		  [20, 60, 17, 60, 20, 60, 17, 180],
		  
		  // SOS Morse Code (unchanged)
		  [40, 40, 40, 40, 40, 120, 120, 80, 120, 80, 120, 120, 40, 40, 40, 40, 40, 800],
		  
		  // Drum Roll Crescendo (NEW - actual drum roll feel)
		  [25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25,  // 16th note rolls
		   50, 50,  // Half note hit
		   100, 400],  // Final hit with decay
		  
		  // Alert Siren (NEW - rising/falling pattern)
		  [200, 50, 250, 50, 300, 50,  // Rising intensity
		   300, 50, 250, 50, 200, 50,  // Falling intensity
		   0, 200],  // Pause at end
		  
		  // Machine-gun Burst (unchanged)
		  [15, 50, 15, 50, 15, 50, 15, 50, 15, 50, 15, 50, 15, 50, 15, 50, 15, 50, 15, 50],
		  
		  // Binary Rhythm (unchanged)
		  [20, 140, 20, 140, 20, 140, 20, 140, 800],

		  // Waltz (3/4 time signature)
		  [80, 40, 40, 40, 40, 40, 80, 40, 40, 40, 40, 40],
		  
		  // Rock Backbeat (4/4 with snare emphasis)
		  [60, 20, 20, 20, 100, 20, 20, 20, 60, 20, 20, 20, 100, 20, 20, 20],
		  
		  // Ease In
		  [15,160,15,80,15,40,15,20,15,10,15,5,20,1000],

		  //Ease Out
		  [15, 5, 15, 10, 15, 20, 15, 40, 15, 80, 15, 160, 15, 250, 15, 500, 20,1000]
		];

		intensities = [
		  // Ring 1 (unchanged)
		  [192, 0, 192, 0, 192, 0, 192, 0, 192, 0, 192, 0, 192, 0, 192, 0, 192, 0, 192, 0, 192, 0, 192, 0, 192, 0, 192, 0, 192, 0, 0, 192, 0, 192, 0, 192, 0, 192, 0, 192, 0, 192, 0, 192, 0, 192, 0, 192, 0, 192, 0, 192, 0, 192, 0, 192, 0, 192, 0, 192, 0, 0],
		  
		  // Ring 2 (unchanged)
		  [192, 0, 192, 0, 192, 0, 192, 0, 192, 0, 192, 0, 192, 0, 192, 0, 192, 0, 192, 0, 192, 0, 192, 0, 192, 0, 192, 0, 192, 0, 192, 0, 192, 0, 192, 0, 192, 0, 192, 0, 192, 0, 192, 0, 192, 0, 192, 0, 192, 0, 192, 0, 192, 0, 192, 0, 192, 0, 192, 0, 192, 0, 192, 0, 192, 0, 192, 0, 192, 0, 192, 0, 192, 0, 192, 0, 192, 0, 192, 0, 192, 0, 192, 0, 192, 0, 192, 0, 192, 0, 192, 0, 192, 0, 192, 0, 192, 0, 192, 0, 192, 0, 192, 0, 192, 0, 192, 0, 192, 0, 192, 0, 192, 0, 192, 0, 192, 0, 192, 0, 192, 0, 192, 0, 192, 0, 192, 0, 192, 0, 192, 0, 192, 0, 192, 0, 192, 0, 192, 0, 192, 0, 192, 0, 192, 0],
		  
		  //Ring 3
		  [230,0,255,0,230,0,255,0,230,0,255,0,255,0,255,0,196,0],

		  // Heartbeat (unchanged)
		  [0, 0, 255, 0, 0, 0, 225, 0],
		  
		  // SOS Morse Code (unchanged)
		  [255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0],
		  
		  // Drum Roll Crescendo (NEW)
		  [100, 0, 120, 0, 140, 0, 160, 0, 180, 0, 200, 0, 220, 0, 240, 0,  // Increasing intensity
		   255, 0,  // Peak hit
		   255, 0],  // Sustain with decay
		  
		  // Alert Siren (NEW)
		  [100, 0, 150, 0, 200, 0,  // Rising amplitude
		   200, 0, 150, 0, 100, 0,  // Falling amplitude
		   0, 0],  // Full stop
		  
		  // Machine-gun Burst (unchanged)
		  [255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0],
		  
		  // Binary Rhythm (unchanged)
		  [255, 0, 255, 0, 255, 0, 255, 0, 0],

		  // Waltz (strong-weak-weak pattern)
		  [220, 0, 180, 0, 160, 0, 220, 0, 180, 0, 160, 0],
		  
		  // Rock Backbeat (kick-snare alternation)
		  [255, 0, 0, 0, 220, 0, 0, 0, 255, 0, 0, 0, 220, 0, 0, 0],

		  // Ease In
		  [120,0,140,0,160,0,180,0,200,0,220,0,240,0],

		  // Ease Out
		  [80,0,100,0,120,0,140,0,160,0,180,0,200,0,220,0,255,0]
		];

		names = [
		  "Ring 1",
		  "Ring 2",
		  "Ring 3",
		  "Heartbeat",
		  "SOS Morse Code",
		  "Drum Roll Crescendo",
		  "Alert Siren",
		  "Machine-gun Burst",
		  "Binary Rhythm",
		  "Waltz Beat",
		  "Rock Backbeat",
		  "Ease In",
		  "Ease Out"
		];

		playing = List.filled(currentPageIndex==0? names.length : myNames.length, false);
		return MaterialApp(
			theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
	    darkTheme: ThemeData.dark(),
	    themeMode: ThemeMode.system,
			home: MainApp(),
		);
	}

  @override
  void dispose() {
    _listener.dispose();
    super.dispose();
  }
}

void checkVersion(BuildContext context) async{
	http.read(Uri.https('prajwal8074.github.io', '/haptics_website/version.txt')).then((versionStr){
		if(double.parse(versionStr) > version)
		{
			http.read(Uri.https('prajwal8074.github.io', '/haptics_website/whatsNew.txt')).then((whatsNew){
				showDialog<void>(
		      context: context,
		      builder: (BuildContext context) {
		        return AlertDialog(
		          title: Text('Update Avaiable', style: Theme.of(context).textTheme.titleLarge),
		          content: Text(whatsNew),
		          actions: <Widget>[
		            TextButton(
		              style: TextButton.styleFrom(
		                textStyle: Theme.of(context).textTheme.labelLarge,
		              ),
		              child: const Text('OK'),
		              onPressed: () {Navigator.of(context).pop();},
		            ),
		            TextButton(
		              style: TextButton.styleFrom(
		                textStyle: Theme.of(context).textTheme.labelLarge,
		              ),
		              child: const Text('Check'),
		              onPressed: () {Navigator.of(context).pop();launchUrl(Uri.parse('https://prajwal8074.github.io/haptics_website/'));},
		            ),
		          ],
		        );
		      },
		    );
			});
	  }
	});
}

Future<void> getHRs() async {
  myPatterns = [];
	myIntensities = [];
	myNames = [];
	hrs = await getAllFilesWithExtension(directory, ".hr.txt");
	for(File hr in hrs)
	{
		List<String> haptics = (await hr.readAsString()).split('\n');
  	myPatterns.add(haptics[0]
		    							.replaceAll('[', '')
		                  .replaceAll(']', '').split(',')
		                  .map<int>(int.parse).toList());
  	myIntensities.add(haptics[1]
		    							.replaceAll('[', '')
		                  .replaceAll(']', '').split(',')
		                  .map<int>(int.parse).toList());
		myNames.add(Path.basename(hr.path.substring(0, hr.path.length-7)));
	}
	return;
}

class MainApp extends StatefulWidget {
	const MainApp({super.key});
	
	@override
	State<MainApp> createState() => _MainState();
}

class _MainState extends State<MainApp> with SingleTickerProviderStateMixin {

  bool _isOpened = false;
  late AnimationController _animationController;
  late Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    checkSupport(context);
    checkVersion(context);
    _isOpened = false;
		_animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 200))
			..addListener(() {
            // call `build` on animation progress
            setState((){});
          });
		_progress = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.0, 1.0, curve: Curves.easeOut),
    ));
  }

  @override
	Widget build(BuildContext context) {
		final ColorScheme colorScheme = Theme.of(context).colorScheme;

		Function setRingtone = (List<int> pattern, List<int> intensities){
			setFile.writeAsString(setName+'\n'+pattern.toString()+'\n'+intensities.toString())
				.whenComplete((){
					methodChannel.invokeMethod('enableSilentMode');
					ScaffoldMessenger.of(context).showSnackBar(SnackBar(
				  	content: Text('Ringtone has been set'),
					));
			});
		};
		
		return Scaffold(
			drawer: NavigationDrawer(
        onDestinationSelected:  (int index) {
        	switch(index)
        	{
	        	case 0: showDialog<void>(
					      context: context,
					      builder: (BuildContext context) {
					        return AlertDialog(
					          title: Text('Tutorial', style: Theme.of(context).textTheme.titleLarge),
					          content: const Text(
					            'Put phone in silent mode\n\nLaunchpad Usage: long press on right tiles and tap on left tiles\n\nLaunchpad Customization: long press on left tiles and tap on right tiles',
					          ),
					          actions: <Widget>[
					            TextButton(
					              style: TextButton.styleFrom(
					                textStyle: Theme.of(context).textTheme.labelLarge,
					              ),
					              child: const Text('OK'),
					              onPressed: () {Navigator.of(context).pop();},
					            ),
					          ],
					        );
					      },
					    );break;
	        	case 1: launchUrl(Uri.parse('https://prajwal8074.github.io/haptics_website/'));break;
	        	case 2: launchUrl(Uri.parse('mailto:prajwal8074@gmail.com?subject=Regarding%20Haptic%20Ringtones'));break;
	        }
	      },
        selectedIndex: null,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 35, 16, 20),
            child: Text(
              'Version $version (2024)', style: TextStyle(fontWeight: FontWeight.bold)
            ),
          ),
          /*NavigationDrawerDestination(
            label: Text("Home"),
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
        	),*/
          /*NavigationDrawerDestination(
            label: Text("Purchase"),
            icon: Icon(Icons.workspace_premium_outlined),
            selectedIcon: Icon(Icons.workspace_premium),
        	),*/
          NavigationDrawerDestination(
            label: Text("How to use"),
            //icon: Icon(Icons.question_mark_outlined),
            //selectedIcon: Icon(Icons.question_mark),
            icon: Icon(Icons.question_mark),
        	),
        	NavigationDrawerDestination(
            label: Text("Explore"),
            //icon: Icon(Icons.reviews_outlined),
            //selectedIcon: Icon(Icons.reviews),
            icon: Icon(Icons.explore),
        	),
          /*NavigationDrawerDestination(
            label: Text("Settings"),
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
        	),*/
          NavigationDrawerDestination(
            label: Text("Contact"),
            //icon: Icon(Icons.email_outlined),
            //selectedIcon: Icon(Icons.email),
            icon: Icon(Icons.contact_support),
        	),
        ],
      ),
			appBar : AppBar(
				title : const Text("Haptic Ringtones", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
			body: ListView(
        children: currentPageIndex == 0? List<Widget>.generate(names.length, (i) {
					int randomNumber = random.nextInt(100);
			    return ListTile(
		        selected: (setName==names[i]),
		        titleAlignment: ListTileTitleAlignment.center,
		        leading: playing[i]? Icon(Icons.pause_rounded) : Icon(Icons.play_arrow_rounded),
		        title: Text(names[i]),
		        //subtitle: Text('$randomNumber devices'),
		        onTap: () {
		          setState(() {
		            // This is called when the user toggles the switch.
		            bool isPlaying = playing[i];
		            for(int j=0;j<playing.length;j++)
		            	playing[j] = false;
		            Vibration.cancel();
		            playing[i] = !isPlaying;
		            if(playing[i])
		            	Vibration.vibrate(pattern: patterns[i], intensities: intensities[i], repeat: 0);
		          });
		        },
		        trailing: PopupMenuButton<int>(
		          onSelected: (int value) {
		          	switch(value)
		          	{
		          		case 0: setName = names[i];setRingtone(patterns[i], intensities[i]);setState((){});break;
		          	}
		          },
		          itemBuilder: (BuildContext context) =>
	            <PopupMenuEntry<int>>[
		            const PopupMenuItem<int>(
		              value: 0,
		              child: Text('Set'),
		            ),
	            ],
		        ),
		      );
				}) : (myNames.length>0? List<Widget>.generate(myNames.length, (i) {
			    return ListTile(
		        selected: (setName==myNames[i]),
		        titleAlignment: ListTileTitleAlignment.center,
		        leading: playing[i]? Icon(Icons.pause_rounded) : Icon(Icons.play_arrow_rounded),
		        title: Text(myNames[i]),
		        //subtitle: const Text('100 devices'),
		        onTap: () {
		          setState(() {
		            // This is called when the user toggles the switch.
		            bool isPlaying = playing[i];
		            for(int j=0;j<playing.length;j++)
		            	playing[j] = false;
		            Vibration.cancel();
		            playing[i] = !isPlaying;
		            if(playing[i])
		            	Vibration.vibrate(pattern: myPatterns[i], intensities: myIntensities[i], repeat: 0);
		          });
		        },
		        trailing: PopupMenuButton<int>(
		          onSelected: (int value) {
		          	switch(value)
		          	{
		          		case 0: setName = myNames[i];setRingtone(myPatterns[i], myIntensities[i]);setState((){});break;
		          		case 1: Share.shareXFiles([XFile('${directory}/${myNames[i]}.hr.txt')], text: 'Share Haptic Ringtone');break;
		          		case 2: showDialog<void>(
											      context: context,
											      builder: (BuildContext context) {
											        return AlertDialog(
											          title: Text('Delete', style: Theme.of(context).textTheme.titleLarge),
											          content: Text('Are you sure you want to delete?'),
											          actions: <Widget>[
											            TextButton(
											              style: TextButton.styleFrom(
											                textStyle: Theme.of(context).textTheme.labelLarge,
											              ),
											              child: const Text('Cancel'),
											              onPressed: () {Navigator.of(context).pop();},
											            ),
											            TextButton(
											              style: TextButton.styleFrom(
											                textStyle: Theme.of(context).textTheme.labelLarge,
											              ),
											              child: const Text('Delete'),
											              onPressed: () {hrs[i].delete();getHRs().then((_){setState((){playing = List.filled(currentPageIndex==0? names.length : myNames.length, false);});});Navigator.of(context).pop();},
											            ),
											          ],
											        );
											      },
											    );break;
		          	}
		          },
		          itemBuilder: (BuildContext context) =>
	            <PopupMenuEntry<int>>[
		            const PopupMenuItem<int>(
		              value: 0,
		              child: Text('Set'),
		            ),
		            const PopupMenuItem<int>(
		              value: 1,
		              child: Text('Share'),
	              ),
		            const PopupMenuItem<int>(
		              value: 2,
		              child: Text('Delete'),
	              ),
	            ],
		        ),
		      );
				}) : [Center(child: Text("You have not created any ringtones"))]),
      ),
      floatingActionButton: SpeedDial(
        foregroundColor: colorScheme.onSecondaryContainer,
        backgroundColor: colorScheme.secondaryContainer,
        child: SimpleAnimatedIcon(
		      startIcon: Icons.add,
		      endIcon: Icons.close,
		      progress: _progress,
		    ),
        onOpen: () {
			     _animationController.forward();
			    setState(() {
			      _isOpened = !_isOpened;
			    });
			  },
        onClose: () {
			    _animationController.reverse();
			    setState(() {
			      _isOpened = !_isOpened;
			    });
			  },
        //animatedIcon: AnimatedIcons.menu_close,
        children: [
        	SpeedDialChild(
        		child: Icon(Icons.arrow_outward_rounded),
        		label: "Import",
        		onTap: (){
        			pickHR().then((hr){
        				if(hr != null && hr.path.endsWith(".hr.txt"))
        				{
        					hr.readAsString().then((str){
	        					File(directory+'/'+Path.basename(hr.path)).writeAsString(str)
											.whenComplete((){
												ScaffoldMessenger.of(context).showSnackBar(SnackBar(
											  	content: Text(Path.basename(hr.path.substring(0, hr.path.length-7))+' saved'),
												));
												getHRs().then((_){setState((){playing = List.filled(currentPageIndex==0? names.length : myNames.length, false);});});
										});
									});
        				}else{
        					ScaffoldMessenger.of(context).showSnackBar(SnackBar(
								  	content: Text('Select a valid file'),
									));
        				}
        			});
        		},
        	),
        	SpeedDialChild(
        		child: Icon(Icons.create_rounded),
        		label: "Create",
        		onTap: (){
        			Vibration.cancel();
		          Navigator.push(
						    context,
						    MaterialPageRoute(builder: (context) => const Studio()),
						  ).then((_){Vibration.cancel();getHRs().then((_){setState((){playing = List.filled(currentPageIndex==0? names.length : myNames.length, false);});});});
						},
        	),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        selectedIndex: currentPageIndex,
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
						playing = List.filled(currentPageIndex==0? names.length : myNames.length, false);
						Vibration.cancel();
          });
        },
        destinations: const <Widget>[
          NavigationDestination(
          	selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
          	selectedIcon: Icon(Icons.my_library_music),
            icon: Icon(Icons.my_library_music_outlined),
            label: 'Saved',
          ),
        ],
      ),
		);
	}
	Future<File?> pickHR() async {
		const XTypeGroup typeGroup = XTypeGroup(
		  label: 'text',
		  extensions: <String>['txt'],
		);
		XFile? xFile = await openFile(acceptedTypeGroups: <XTypeGroup>[typeGroup]);
		return (xFile==null)? null : File(xFile.path);
	}
}

class Studio extends StatefulWidget {
	const Studio({super.key});

	@override
	State<Studio> createState() => _StudioState();
}

class _StudioState extends State<Studio>{
  List<List<int>> haptics = 
  [
    [6, 128],
    [6, 192],
    [8, 192],
    [8, 255],
  ];
  List<List<int>> vibrations = 
  [
    [800, 32],
    [800, 128],
    [800, 255],
  ];

  List<int> pattern = [];
  List<int> intensities = [];
  int startTimeMillis = 0;

  double maxDuration = 100;
  double maxDurationVibration = 2000;

  final saveAsController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

	@override
	Widget build(BuildContext context) {
		final ColorScheme colorScheme = Theme.of(context).colorScheme;

		return Scaffold(
			backgroundColor: Colors.grey[700],
			appBar : AppBar(
				backgroundColor : Colors.grey[700], 
				title : const Text("Launchpad"),
				actions: [
          IconButton(
            icon: const Icon(Icons.save_rounded),
            tooltip: 'Save',
            onPressed: pattern.length==0? null : () 
            {
            	if(startTimeMillis==1)
            		Vibration.cancel();
            	else
            	if(startTimeMillis>1)
            	{
								pattern.add(DateTime.now().millisecondsSinceEpoch-startTimeMillis);
								intensities.add(0);
							}
            	startTimeMillis = 0;
							setState((){});

							Function saveAs = (String name) async
							{
								File(directory+'/'+name+'.hr.txt').writeAsString(pattern.toString()+'\n'+intensities.toString())
									.whenComplete((){
										ScaffoldMessenger.of(context).showSnackBar(SnackBar(
									  	content: Text(name+' saved'),
										));
								});
							};

              showDialog<void>(
					      context: context,
					      builder: (BuildContext context) {
					        return AlertDialog(
					          title: Text('Save As', style: Theme.of(context).textTheme.titleLarge),
					          content: TextField(
				              controller: saveAsController,
				              autofocus: true,
				              onSubmitted: (newValue){
							          Navigator.of(context).pop();
							          saveAs(newValue);
							        },
				            ),
					          actions: <Widget>[
					            TextButton(
					              style: TextButton.styleFrom(
					                textStyle: Theme.of(context).textTheme.labelLarge,
					              ),
					              child: const Text('Cancel'),
					              onPressed: () {Navigator.of(context).pop();},
					            ),
					            TextButton(
					              style: TextButton.styleFrom(
					                textStyle: Theme.of(context).textTheme.labelLarge,
					              ),
					              child: const Text('Save'),
					              onPressed: () {
					              	Navigator.of(context).pop();
					              	saveAs(saveAsController.text);
					              },
					            ),
					          ],
					        );
					      },
					    );
            },
          ),
      	],
      ),
			body: Row(
				mainAxisAlignment: MainAxisAlignment.center,
				children: [
					Expanded(
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.stretch,
							children: [
								Expanded(
									child: Padding(
										padding: EdgeInsets.all(5),
										child: GestureDetector(
										  onLongPress: (){changeButtonVibration(context, 0, true).then((_)=>setState((){}));},
										  child: FloatingActionButton.extended(
												onPressed: (){
													if(pattern.length > 0)
													{
														if(startTimeMillis > 1)
														{
															pattern.add(DateTime.now().millisecondsSinceEpoch-startTimeMillis);
															intensities.add(0);
														}else{
															pattern.clear();
															intensities.clear();
															if(startTimeMillis == 1)
																Vibration.cancel();
														}
													}
													pattern.add(haptics[0][0]);
													intensities.add(haptics[0][1]);
													haptic(haptics[0][0], haptics[0][1]);
													Future.delayed(Duration(milliseconds: haptics[0][0]), () {
														startTimeMillis = DateTime.now().millisecondsSinceEpoch;
														setState((){});
													});
												},
												heroTag: null,
												foregroundColor: Colors.white,
                  			backgroundColor: Color.fromRGBO(haptics[0][1], 32, (haptics[0][0]/maxDuration*255).toInt(), 1),
												label: Text(haptics[0][0].toString()+' '+haptics[0][1].toString()),
											)
										)
									)
								),
								Expanded(
									child: Padding(
										padding: EdgeInsets.all(5),
										child: GestureDetector(
										  onLongPress: (){changeButtonVibration(context, 1, true).then((_)=>setState((){}));},
										  child:  FloatingActionButton.extended(
												onPressed: (){
													if(pattern.length > 0)
													{
														if(startTimeMillis > 1)
														{
															pattern.add(DateTime.now().millisecondsSinceEpoch-startTimeMillis);
															intensities.add(0);
														}else{
															pattern.clear();
															intensities.clear();
															if(startTimeMillis == 1)
																Vibration.cancel();
														}
													}
													pattern.add(haptics[1][0]);
													intensities.add(haptics[1][1]);
													haptic(haptics[1][0], haptics[1][1]);
													Future.delayed(Duration(milliseconds: haptics[1][0]), () {
														startTimeMillis = DateTime.now().millisecondsSinceEpoch;
														setState((){});
													});
												},
												heroTag: null,
												label: Text(haptics[1][0].toString()+' '+haptics[1][1].toString()),
												foregroundColor: Colors.white,
                  			backgroundColor: Color.fromRGBO(haptics[1][1], 32, (haptics[1][0]/maxDuration*255).toInt(), 1),
											)
										)
									)
								),
								Expanded(
									child: Padding(
										padding: EdgeInsets.all(5),
										child:  GestureDetector(
										  onLongPress: (){changeButtonVibration(context, 2, true).then((_)=>setState((){}));},
										  child: FloatingActionButton.extended(
												onPressed: (){
													if(pattern.length > 0)
													{
														if(startTimeMillis > 1)
														{
															pattern.add(DateTime.now().millisecondsSinceEpoch-startTimeMillis);
															intensities.add(0);
														}else{
															pattern.clear();
															intensities.clear();
															if(startTimeMillis == 1)
																Vibration.cancel();
														}
													}
													pattern.add(haptics[2][0]);
													intensities.add(haptics[2][1]);
													haptic(haptics[2][0], haptics[2][1]);
													Future.delayed(Duration(milliseconds: haptics[2][0]), () {
														startTimeMillis = DateTime.now().millisecondsSinceEpoch;
														setState((){});
													});
												},
												heroTag: null,
												label: Text(haptics[2][0].toString()+' '+haptics[2][1].toString()),
												foregroundColor: Colors.white,
                  			backgroundColor: Color.fromRGBO(haptics[2][1], 32, (haptics[2][0]/maxDuration*255).toInt(), 1),
											)
										)
									)
								),
								Expanded(
									child: Padding(
										padding: EdgeInsets.all(5),
										child: GestureDetector(
										  onLongPress: (){changeButtonVibration(context, 3, true).then((_)=>setState((){}));},
										  child:  FloatingActionButton.extended(
												onPressed: (){
													if(pattern.length > 0)
													{
														if(startTimeMillis > 1)
														{
															pattern.add(DateTime.now().millisecondsSinceEpoch-startTimeMillis);
															intensities.add(0);
														}else{
															pattern.clear();
															intensities.clear();
															if(startTimeMillis == 1)
																Vibration.cancel();
														}
													}
													pattern.add(haptics[3][0]);
													intensities.add(haptics[3][1]);
													haptic(haptics[3][0], haptics[3][1]);
													Future.delayed(Duration(milliseconds: haptics[3][0]), () {
														startTimeMillis = DateTime.now().millisecondsSinceEpoch;
														setState((){});
													});
												},
												heroTag: null,
												label: Text(haptics[3][0].toString()+' '+haptics[3][1].toString()),
												foregroundColor: Colors.white,
                  			backgroundColor: Color.fromRGBO(haptics[3][1], 32, (haptics[3][0]/maxDuration*255).toInt(), 1),
											)
										)
									)
								),
							]
						)
					),
					Expanded(
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.stretch,
							children: [
								Expanded(
									child: Padding(
										padding: EdgeInsets.all(5),
										child:  Listener(
											onPointerUp: (_){
												Vibration.cancel();
												pattern.add(DateTime.now().millisecondsSinceEpoch-startTimeMillis);
												intensities.add(vibrations[0][1]);
											},
											onPointerDown: (_){
												if(pattern.length > 0)
												{
													if(startTimeMillis > 1)
													{
														pattern.add(DateTime.now().millisecondsSinceEpoch-startTimeMillis);
														intensities.add(0);
													}else{
														pattern.clear();
														intensities.clear();
														if(startTimeMillis == 1)
															Vibration.cancel();
													}
												}
												haptic(vibrations[0][0], vibrations[0][1]);
												startTimeMillis = DateTime.now().millisecondsSinceEpoch;
												setState((){});
											},
										  child: FloatingActionButton.extended(
										  	onPressed: (){
										  		if(DateTime.now().millisecondsSinceEpoch-startTimeMillis < 125)
										  			changeButtonVibration(context, 0, false).then((_)=>setState((){}));
													startTimeMillis = DateTime.now().millisecondsSinceEpoch;
										  	},
												heroTag: null,
												label: Text('long, ${vibrations[0][1]}'),
												foregroundColor: Colors.white,
                  			backgroundColor: Color.fromRGBO(vibrations[0][1], 32, (vibrations[0][0]/maxDurationVibration*255).toInt(), 1),
											)
										)
									)
								),
								Expanded(
									child: Padding(
										padding: EdgeInsets.all(5),
										child:  Listener(
											onPointerUp: (_){
												Vibration.cancel();
												pattern.add(DateTime.now().millisecondsSinceEpoch-startTimeMillis);
												intensities.add(vibrations[1][1]);
											},
											onPointerDown: (_){
												if(pattern.length > 0)
												{
													if(startTimeMillis > 1)
													{
														pattern.add(DateTime.now().millisecondsSinceEpoch-startTimeMillis);
														intensities.add(0);
													}else{
														pattern.clear();
														intensities.clear();
														if(startTimeMillis == 1)
															Vibration.cancel();
													}
												}
												haptic(vibrations[1][0], vibrations[1][1]);
												startTimeMillis = DateTime.now().millisecondsSinceEpoch;
												setState((){});
											},
										  child: FloatingActionButton.extended(
										  	onPressed: (){
										  		if(DateTime.now().millisecondsSinceEpoch-startTimeMillis < 125)
										  			changeButtonVibration(context, 1, false).then((_)=>setState((){}));
													startTimeMillis = DateTime.now().millisecondsSinceEpoch;
										  	},
												heroTag: null,
												label: Text('long, ${vibrations[1][1]}'),
												foregroundColor: Colors.white,
                  			backgroundColor: Color.fromRGBO(vibrations[1][1], 32, (vibrations[1][0]/maxDurationVibration*255).toInt(), 1),
											)
										)
									)
								),
								Expanded(
									child: Padding(
										padding: EdgeInsets.all(5),
										child:  Listener(
											onPointerUp: (_){
												Vibration.cancel();
												pattern.add(DateTime.now().millisecondsSinceEpoch-startTimeMillis);
												intensities.add(vibrations[2][1]);
											},
											onPointerDown: (_){
												if(pattern.length > 0)
												{
													if(startTimeMillis > 1)
													{
														pattern.add(DateTime.now().millisecondsSinceEpoch-startTimeMillis);
														intensities.add(0);
													}else{
														pattern.clear();
														intensities.clear();
														if(startTimeMillis == 1)
															Vibration.cancel();
													}
												}
												haptic(vibrations[2][0], vibrations[2][1]);
												startTimeMillis = DateTime.now().millisecondsSinceEpoch;
												setState((){});
											},
										  child: FloatingActionButton.extended(
										  	onPressed: (){
										  		if(DateTime.now().millisecondsSinceEpoch-startTimeMillis < 125)
										  			changeButtonVibration(context, 2, false).then((_)=>setState((){}));
													startTimeMillis = DateTime.now().millisecondsSinceEpoch;
										  	},
												heroTag: null,
												label: Text('long, ${vibrations[2][1]}'),
												foregroundColor: Colors.white,
                  			backgroundColor: Color.fromRGBO(vibrations[2][1], 32, (vibrations[2][0]/maxDurationVibration*255).toInt(), 1),
											)
										)
									)
								),
								Expanded(
									child: Padding(
										padding: EdgeInsets.all(5),
										child: FloatingActionButton(
											onPressed: startTimeMillis==0? (pattern.length == 0? null : (){
													Vibration.vibrate(pattern: pattern, intensities: intensities, repeat: 0);
													startTimeMillis = 1;
													setState((){});
												}) : (startTimeMillis==1? (){
													Vibration.cancel();
													startTimeMillis = 0;
													setState((){});
												} : (){
												pattern.add(DateTime.now().millisecondsSinceEpoch-startTimeMillis);
												intensities.add(0);
												startTimeMillis = 0;
												setState((){});
											}),
											heroTag: null,
											child: Icon(startTimeMillis==0? Icons.play_arrow_rounded  : (startTimeMillis==1? Icons.pause_rounded : Icons.stop_rounded)),
											foregroundColor: Colors.white,
											backgroundColor: startTimeMillis==0? (pattern.length == 0? Colors.blue : Colors.green) : (startTimeMillis==1? Colors.green : Colors.red),
										)
									)
								),
							]
						)
					),
				],
			)
		);
	}

	Future<void> changeButtonVibration(BuildContext context, int i, bool isHaptic) async
	{
		int durationValue = isHaptic? haptics[i][0] : vibrations[i][0];
		int amplitudeValue = isHaptic? haptics[i][1] : vibrations[i][1];

		List<int> newHaptic  = await showDialog(context: context, builder: (BuildContext context) => 
			StatefulBuilder(
	      builder: (context, setState) {
	        return AlertDialog(
					  content: Container(
					    child: Column(
					    	mainAxisSize: MainAxisSize.min,
					      children: <Widget>[
					      	Text(isHaptic? 'Duration' : 'Max Duration'),
					        Slider(
						        value: durationValue.toDouble(),
						        max: isHaptic? maxDuration : maxDurationVibration,
						        min: isHaptic? 0.0 : maxDuration,
						        divisions: 50,
						        label: durationValue.round().toString(),
						        onChanged: (double value) {
						          setState(() {
						            durationValue = value.toInt();
						          });
						        },
						      ),
					      	Text('Amplitude'),
						      Slider(
						        value: amplitudeValue.toDouble(),
						        max: 255,
						        divisions: 50,
						        label: amplitudeValue.round().toString(),
						        onChanged: (double value) {
						          setState(() {
						            amplitudeValue = value.toInt();
						          });
						        },
						      ),
					      ],
					    ),
					  ),
			      actions: [
			        TextButton(
			        	onPressed: () {
			          	Navigator.pop(context, isHaptic? haptics[i] : vibrations[i]);
			        	},
			          child: Text('Cancel')
			        ),
			        TextButton(
			        	onPressed: () {
			          	Navigator.pop(context, [durationValue, amplitudeValue]);
			        	},
			          child: Text('Set')
			        ),
			      ],
					);
				}
			)
		);
		if(isHaptic)
			haptics[i] = newHaptic;
		else
			vibrations[i] = newHaptic;
	}

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    saveAsController.dispose();
    super.dispose();
  }
}

void haptic(int duration, int amplitude) async {
	Vibration.vibrate(duration: duration, amplitude: amplitude);
}

Future<void> checkSupport(BuildContext context) async
{
	if (!(await Vibration.hasVibrator()?? true) || !(await Vibration.hasCustomVibrationsSupport()?? true))
  {
    Future.delayed(Duration.zero,() {
  		showDialog<void>(
	      context: context,
	      builder: (BuildContext context) {
	        return AlertDialog(
	          title: Text('Not Supported', style: Theme.of(context).textTheme.titleLarge),
	          content: const Text(
	            'Your device does not support custom vibrations',
	          ),
	          actions: <Widget>[
	            TextButton(
	              style: TextButton.styleFrom(
	                textStyle: Theme.of(context).textTheme.labelLarge,
	              ),
	              child: const Text('OK'),
	              onPressed: () {Navigator.of(context).pop();},
	            ),
	          ],
	        );
	      },
	    );
		});
	}
}

Future<List<File>> getAllFilesWithExtension(String path, String extension) async {
  final List<FileSystemEntity> entities = await Directory(path).list().toList();
  return entities.whereType<File>().where((element) => element.path.endsWith(extension)&&element.path!=setFile.path).toList();
}