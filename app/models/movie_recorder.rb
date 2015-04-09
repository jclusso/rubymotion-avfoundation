class MovieRecorder

  def initialize capture_view, file_name
    @capture_view = capture_view
    @file_name = file_name
    setup
  end

  def record
    @video_output.startRecordingToOutputFileURL(NSURL.fileURLWithPath(local_file_path), recordingDelegate:self)
  end

  def stop_record
    @video_output.stopRecording()
    MovieProcessor.new(@file_name)
  end

  def update_audio_input index
    @session.beginConfiguration
    @session.commitConfiguration
  end

  def update_video_input index
    @session.beginConfiguration
    @session.removeInput(@video_input)
    video_device = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)[index]
    @video_input = AVCaptureDeviceInput.deviceInputWithDevice(video_device, error:error)
    @session.addInput(@video_input)
    @session.commitConfiguration
  end

private

  def setup
    @session = AVCaptureSession.alloc.init
    @session.beginConfiguration
    add_default_audio_input
    add_default_video_input
    add_audio_output 
    add_video_output
    create_capture_view
    @session.setSessionPreset(AVCaptureSessionPreset640x480)
    @session.commitConfiguration
    @session.startRunning()
  end

  def create_capture_view
    preview_layer = AVCaptureVideoPreviewLayer.alloc.initWithSession(@session)
    preview_layer.videoGravity = AVLayerVideoGravityResizeAspectFill
    preview_layer.setFrame(@capture_view.layer.bounds)
    @capture_view.layer.addSublayer(preview_layer)
  end

  def add_video_output 
    @video_output = AVCaptureMovieFileOutput.alloc.init
    @video_output.setDelegate(self)
    @session.addOutput(@video_output)
  end
  
  def add_audio_output 
    @audio_output = AVCaptureAudioPreviewOutput.alloc.init
    @session.addOutput(@audio_output)
  end

  def add_default_audio_input 
    audio_device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeAudio)
    if @audio_input = AVCaptureDeviceInput.deviceInputWithDevice(audio_device, error:error)
        @session.addInput(@audio_input)
    end
  end

  def add_default_video_input 
    video_device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
    if @video_input = AVCaptureDeviceInput.deviceInputWithDevice(video_device, error:error)
        @session.addInput(@video_input)
    end
  end

  def error
    Pointer.new('@')
  end

  def local_file_path
    "#{NSHomeDirectory()}/Desktop/#{@file_name}.mov"
  end

end