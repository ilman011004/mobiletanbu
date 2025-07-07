import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:terra_brain/presentation/controllers/write_controller.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';

class WriteStoryPage extends StatefulWidget {
  const WriteStoryPage({super.key});

  @override
  _WriteStoryPageState createState() => _WriteStoryPageState();
}

class _WriteStoryPageState extends State<WriteStoryPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _storyController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final FlutterSoundRecorder _audioRecorder = FlutterSoundRecorder();
  final WriteController _controller = Get.put(WriteController());

  File? _selectedImage;
  File? _selectedVideo;
  File? _recordedAudio;
  VideoPlayerController? _videoPlayerController;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isRecording = false;
  bool _isAudioPlaying = false;

  // Tambahkan variabel untuk kategori genre
  final List<String> _categories = [
    'Komedi',
    'Horor',
    'Romansa',
    'Thriller',
    'Fantasi',
    'Fiksi Ilmiah',
    'Misteri',
    'Aksi'
  ];
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _initializeRecorder();
    _initAudioPlayer();
    requestMicrophonePermission();
  }

  @override
  void dispose() {
    _audioRecorder.closeRecorder();
    _videoPlayerController?.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _initializeRecorder() async {
    await _audioRecorder.openRecorder();
  }

  Future<void> requestMicrophonePermission() async {
    var status = await Permission.microphone.request();
    if (status.isDenied || status.isPermanentlyDenied) {
      // print("Izin mikrofon diperlukan untuk merekam.");
    } else {
      // print("Izin mikrofon diberikan.");
    }
  }

  void _saveStory() {
  if (_titleController.text.isEmpty) {
    Get.snackbar(
      "Error",
      "Judul cerita tidak boleh kosong.",
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
    );
  } else if (_storyController.text.isEmpty) {
    Get.snackbar(
      "Error",
      "Konten cerita tidak boleh kosong.",
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
    );
  } else if (_selectedCategory == null) {
    Get.snackbar(
      "Error",
      "Silakan pilih kategori cerita.",
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
    );
  } else {
    // Logika penyimpanan cerita
    _controller.uploadData(
      title: _titleController.text,
      content: _storyController.text.replaceAll('\n', '\\n'),
      imageFile: _selectedImage,
      audioFile: _recordedAudio,
      category: _selectedCategory!,
    );
    Navigator.pushReplacementNamed(context, '/home');
  }
}


  Widget _statusConnectionWidget() {
    return Obx(
      () => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _controller.isConnected.value ? Icons.wifi : Icons.wifi_off,
            color: _controller.isConnected.value ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 8),
          Text(
            _controller.isConnected.value ? "Online" : "Offline",
            style: TextStyle(
                color:
                    _controller.isConnected.value ? Colors.green : Colors.red),
          ),
        ],
      ),
    );
  }

  Future<void> _pickMedia(String type, ImageSource source) async {
    XFile? file;

    if (type == 'image') {
      file = await _picker.pickImage(source: source);
      if (file != null) {
        setState(
          () {
            _selectedImage = File(file!.path);
            _selectedVideo = null;
            _videoPlayerController?.dispose();
          },
        );
      }
    } else if (type == 'video') {
      file = await _picker.pickVideo(source: source);
      if (file != null) {
        setState(
          () {
            _selectedVideo = File(file!.path);
            _selectedImage = null;
            _videoPlayerController = VideoPlayerController.file(_selectedVideo!)
              ..addListener(
                () {
                  if (_videoPlayerController!.value.position ==
                      _videoPlayerController!.value.duration) {
                    setState(() {
                      _videoPlayerController!.pause();
                    });
                  }
                },
              )
              ..initialize().then(
                (_) {
                  setState(() {});
                },
              ).catchError(
                (e) {
                  // print("Error initializing video player: $e");
                },
              );
          },
        );
      }
    }
  }

  Future<void> _recordAudio() async {
    if (!_isRecording) {
      Directory tempDir = await getTemporaryDirectory();
      String filePath = '${tempDir.path}/audio_record.aac';

      await _audioRecorder.startRecorder(toFile: filePath);
      setState(
        () {
          _isRecording = true;
        },
      );
    } else {
      String? filePath = await _audioRecorder.stopRecorder();
      setState(
        () {
          _isRecording = false;
          _recordedAudio = filePath != null ? File(filePath) : null;
        },
      );
    }
  }

  void _initAudioPlayer() {
    _audioPlayer.onPlayerComplete.listen(
      (event) {
        setState(
          () {
            _isAudioPlaying = false;
          },
        );
      },
    );
  }

  Future<void> _toggleAudioPlayback() async {
    if (_isAudioPlaying) {
      await _audioPlayer.pause();
    } else {
      if (_recordedAudio != null) {
        await _audioPlayer.play(DeviceFileSource(_recordedAudio!.path));
      }
    }
    setState(
      () {
        _isAudioPlaying = !_isAudioPlaying;
      },
    );
  }

  Widget _imageVideoPreview() {
    if (_selectedImage != null) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.file(
              _selectedImage!,
              fit: BoxFit.cover,
              height: 200,
              width: double.infinity,
            ),
          ),
          Positioned(
            bottom: 10,
            right: 10,
            child: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red, size: 30),
              onPressed: () {
                setState(
                  () {
                    _selectedImage = null;
                  },
                );
              },
            ),
          ),
        ],
      );
    } else if (_selectedVideo != null &&
        _videoPlayerController != null &&
        _videoPlayerController!.value.isInitialized) {
      return Stack(
        children: [
          SizedBox(
            height: 200,
            width: double.infinity,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: VideoPlayer(_videoPlayerController!),
            ),
          ),
          Center(
            child: IconButton(
              icon: Icon(
                _videoPlayerController!.value.isPlaying
                    ? Icons.pause
                    : Icons.play_arrow,
                color: Colors.white,
                size: 50,
              ),
              onPressed: () {
                setState(() {
                  if (_videoPlayerController!.value.isPlaying) {
                    _videoPlayerController!.pause();
                  } else {
                    _videoPlayerController!.play();
                  }
                });
              },
            ),
          ),
          Positioned(
            bottom: 10,
            right: 10,
            child: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red, size: 30),
              onPressed: () {
                setState(() {
                  _selectedVideo = null;
                  _videoPlayerController?.dispose();
                  _videoPlayerController = null;
                });
              },
            ),
          ),
        ],
      );
    }
    return const Text(
      'Ketuk untuk menambahkan gambar atau video',
      style: TextStyle(color: Colors.grey, fontSize: 16),
    );
  }

  Widget _audioPreview() {
    if (_recordedAudio != null) {
      return Stack(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Row(
              children: [
                const Icon(Icons.audiotrack, color: Colors.orange, size: 30),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Audio Terekam',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _isAudioPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.orange,
                    size: 30,
                  ),
                  onPressed: _toggleAudioPlayback,
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red, size: 30),
                  onPressed: () {
                    setState(() {
                      _recordedAudio = null;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      );
    }
    return GestureDetector(
      onTap: _recordedAudio == null ? _recordAudio : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Row(
          children: [
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Ketuk untuk merekam audio',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            Icon(
              _isRecording ? Icons.stop : Icons.mic,
              color: _isRecording ? Colors.red : Colors.orange,
              size: 30,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: const BackButton(color: Colors.white),
        backgroundColor: Colors.deepPurple[700],
        title: const Text(
          'Tulis Ceritamu',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          _statusConnectionWidget(),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Dropdown untuk kategori
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.deepPurpleAccent),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCategory == "Pilih Genre"
                      ? null
                      : _selectedCategory,
                  icon: const Icon(Icons.arrow_drop_down,
                      color: Colors.deepPurpleAccent),
                  iconSize: 24,
                  elevation: 16,
                  style: const TextStyle(color: Colors.white),
                  dropdownColor: Colors.grey[900],
                  hint: const Text("Pilih Genre",
                      style: TextStyle(color: Colors.grey)),
                  onChanged: (String? newValue) {
                    setState(
                      () {
                        _selectedCategory = newValue!;
                      },
                    );
                  },
                  items: [
                    const DropdownMenuItem<String>(
                      value: "Pilih Genre",
                      enabled: false, // Tidak dapat dipilih
                      child: Text(
                        "Pilih Genre",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    ..._categories.map<DropdownMenuItem<String>>(
                      (String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(15)),
                  ),
                  builder: (context) {
                    return Wrap(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.camera_alt,
                              color: Colors.deepPurple),
                          title: const Text('Ambil Gambar'),
                          onTap: () {
                            Navigator.pop(context);
                            _pickMedia('image', ImageSource.camera);
                          },
                        ),
                        ListTile(
                          leading:
                              const Icon(Icons.image, color: Colors.deepPurple),
                          title: const Text('Pilih Gambar dari Galeri'),
                          onTap: () {
                            Navigator.pop(context);
                            _pickMedia('image', ImageSource.gallery);
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.videocam,
                              color: Colors.deepPurple),
                          title: const Text('Rekam Video'),
                          onTap: () {
                            Navigator.pop(context);
                            _pickMedia('video', ImageSource.camera);
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.video_library,
                              color: Colors.deepPurple),
                          title: const Text('Pilih Video dari Galeri'),
                          onTap: () {
                            Navigator.pop(context);
                            _pickMedia('video', ImageSource.gallery);
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.deepPurpleAccent),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.deepPurple[700]!, Colors.deepPurple[300]!],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurpleAccent.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Center(child: _imageVideoPreview()),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.deepPurpleAccent),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurpleAccent.withOpacity(0.2),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Center(
                child: _audioPreview(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Judul Ceritamu',
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[900],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Scrollbar(
              child: SingleChildScrollView(
                child: TextField(
                  controller: _storyController,
                  style: const TextStyle(color: Colors.white),
                  maxLines: null,
                  decoration: InputDecoration(
                    hintText: 'Tulis ceritamu...',
                    hintStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey[900],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Obx(
              () {
                if (_controller.isUploading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                return ElevatedButton(
                  onPressed: _saveStory,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.deepPurple[600],
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text('Unggah Cerita',
                      style: TextStyle(fontSize: 18)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
