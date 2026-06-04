import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:quickpick/product/pick/pick_preview_page.dart';

class PickCreatePage extends StatefulWidget {
  const PickCreatePage({super.key});

  @override
  State<PickCreatePage> createState() => _PickCreatePageState();
}

class _PickCreatePageState extends State<PickCreatePage> {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isInitialized = false;
  int _selectedCamera = 0;

  double _currentZoom = 1.0;
  double _baseZoom = 1.0;
  double _minZoom = 1.0;
  double _maxZoom = 1.0;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    if (_cameras.isEmpty) {
      return;
    }

    _controller = CameraController(
      _cameras[_selectedCamera],
      ResolutionPreset.max,
      enableAudio: false,
    );

    await _controller!.initialize();
    _minZoom = await _controller!.getMinZoomLevel();
    _maxZoom = await _controller!.getMaxZoomLevel();
    _currentZoom = _minZoom;

    if (mounted) {
      setState(() => _isInitialized = true);
    }
  }

  Future<void> _flipCamera() async {
    if (_cameras.length < 2) {
      return;
    }
    _selectedCamera = _selectedCamera == 0 ? 1 : 0;

    await _controller?.dispose();
    setState(() => _isInitialized = false);
    await _initCamera();
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_isInitialized) {
      return;
    }
    final image = await _controller!.takePicture();
    if (!mounted) {
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PickPreviewPage(imagePath: image.path),
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (_isInitialized && _controller != null)
            GestureDetector(
              onScaleStart: (_) => _baseZoom = _currentZoom,
              onScaleUpdate: (details) async {
                final newZoom =
                    (_baseZoom * details.scale).clamp(_minZoom, _maxZoom);
                await _controller!.setZoomLevel(newZoom);
                setState(() => _currentZoom = newZoom);
              },
              child: Center(
                child: AspectRatio(
                  aspectRatio: _controller!.value.previewSize!.height /
                      _controller!.value.previewSize!.width,
                  child: CameraPreview(_controller!),
                ),
              ),
            )
          else
            const Center(child: CircularProgressIndicator(color: Colors.white)),
          if (_isInitialized)
            Positioned(
              bottom: 130,
              left: 0,
              right: 0,
              child: Center(
                child: AnimatedOpacity(
                  opacity: _currentZoom > _minZoom + 0.05 ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_currentZoom.toStringAsFixed(1)}×',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ),
            ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close,
                            color: Colors.white, size: 28),
                        onPressed: () => Navigator.pop(context),
                      ),
                      IconButton(
                        icon: const Icon(Icons.flip_camera_ios,
                            color: Colors.white, size: 28),
                        onPressed: _flipCamera,
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: GestureDetector(
                    onTap: _takePicture,
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                      ),
                      child: Center(
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
