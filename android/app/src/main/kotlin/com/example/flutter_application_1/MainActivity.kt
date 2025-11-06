package com.example.flutter_application_1

import android.content.Context
import android.graphics.BitmapFactory
import androidx.annotation.NonNull
import com.google.mediapipe.framework.image.BitmapImageBuilder
import com.google.mediapipe.framework.image.MPImage
import com.google.mediapipe.tasks.genai.llminference.LlmInference
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.flutter_application_1/mediapipe_llm"
    private val EVENT_CHANNEL = "com.example.flutter_application_1/mediapipe_llm_stream"
    
    private var llmInference: LlmInference? = null
    private var streamEventSink: EventChannel.EventSink? = null
    private val coroutineScope = CoroutineScope(Dispatchers.Main)

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Setup method channel for synchronous calls
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "initialize" -> {
                    val modelPath = call.argument<String>("modelPath")
                    val maxTokens = call.argument<Int>("maxTokens") ?: 1000
                    val topK = call.argument<Int>("topK") ?: 64
                    val temperature = call.argument<Double>("temperature") ?: 0.8
                    val randomSeed = call.argument<Int>("randomSeed") ?: 101
                    
                    if (modelPath != null) {
                        initializeLlm(modelPath, maxTokens, topK, temperature.toFloat(), randomSeed, result)
                    } else {
                        result.error("INVALID_ARGUMENT", "Model path is required", null)
                    }
                }
                "generateResponse" -> {
                    val prompt = call.argument<String>("prompt")
                    val imageData = call.argument<ByteArray>("imageData")
                    
                    if (prompt != null) {
                        generateResponse(prompt, imageData, result)
                    } else {
                        result.error("INVALID_ARGUMENT", "Prompt is required", null)
                    }
                }
                "generateResponseAsync" -> {
                    val prompt = call.argument<String>("prompt")
                    val imageData = call.argument<ByteArray>("imageData")
                    
                    if (prompt != null) {
                        generateResponseAsync(prompt, imageData)
                        result.success(true)
                    } else {
                        result.error("INVALID_ARGUMENT", "Prompt is required", null)
                    }
                }
                "dispose" -> {
                    disposeLlm()
                    result.success(true)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }

        // Setup event channel for streaming responses
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    streamEventSink = events
                }

                override fun onCancel(arguments: Any?) {
                    streamEventSink = null
                }
            }
        )
    }

    private fun initializeLlm(
        modelPath: String,
        maxTokens: Int,
        topK: Int,
        temperature: Float,
        randomSeed: Int,
        result: MethodChannel.Result
    ) {
        coroutineScope.launch(Dispatchers.IO) {
            try {
                val options = LlmInference.LlmInferenceOptions.builder()
                    .setModelPath(modelPath)
                    .setMaxTokens(maxTokens)
                    .setTopK(topK)
                    .setTemperature(temperature)
                    .setRandomSeed(randomSeed)
                    .build()

                llmInference = LlmInference.createFromOptions(applicationContext, options)
                
                launch(Dispatchers.Main) {
                    result.success(true)
                }
            } catch (e: Exception) {
                launch(Dispatchers.Main) {
                    result.error("INITIALIZATION_ERROR", "Failed to initialize LLM: ${e.message}", null)
                }
            }
        }
    }

    private fun generateResponse(
        prompt: String,
        imageData: ByteArray?,
        result: MethodChannel.Result
    ) {
        coroutineScope.launch(Dispatchers.IO) {
            try {
                if (llmInference == null) {
                    launch(Dispatchers.Main) {
                        result.error("NOT_INITIALIZED", "LLM has not been initialized", null)
                    }
                    return@launch
                }

                val response = if (imageData != null) {
                    // Multimodal inference with image
                    val bitmap = BitmapFactory.decodeByteArray(imageData, 0, imageData.size)
                    val mpImage = BitmapImageBuilder(bitmap).build()
                    
                    // Create session with vision support
                    val sessionOptions = LlmInference.LlmInferenceSession.LlmInferenceSessionOptions.builder()
                        .setTopK(64)
                        .setTemperature(0.8f)
                        .build()
                    
                    llmInference!!.createSession(sessionOptions).use { session ->
                        session.addQueryChunk(prompt)
                        session.addImage(mpImage)
                        session.generateResponse()
                    }
                } else {
                    // Text-only inference
                    llmInference!!.generateResponse(prompt)
                }

                launch(Dispatchers.Main) {
                    result.success(response)
                }
            } catch (e: Exception) {
                launch(Dispatchers.Main) {
                    result.error("INFERENCE_ERROR", "Failed to generate response: ${e.message}", null)
                }
            }
        }
    }

    private fun generateResponseAsync(prompt: String, imageData: ByteArray?) {
        coroutineScope.launch(Dispatchers.IO) {
            try {
                if (llmInference == null) {
                    streamEventSink?.error("NOT_INITIALIZED", "LLM has not been initialized", null)
                    return@launch
                }

                if (imageData != null) {
                    // Multimodal streaming with image
                    val bitmap = BitmapFactory.decodeByteArray(imageData, 0, imageData.size)
                    val mpImage = BitmapImageBuilder(bitmap).build()
                    
                    val sessionOptions = LlmInference.LlmInferenceSession.LlmInferenceSessionOptions.builder()
                        .setTopK(64)
                        .setTemperature(0.8f)
                        .build()
                    
                    llmInference!!.createSession(sessionOptions).use { session ->
                        session.addQueryChunk(prompt)
                        session.addImage(mpImage)
                        
                        val responseStream = session.generateResponseAsync()
                        responseStream.collect { partialResult ->
                            launch(Dispatchers.Main) {
                                streamEventSink?.success(partialResult)
                            }
                        }
                    }
                } else {
                    // Text-only streaming
                    llmInference!!.generateResponseAsync(prompt) { partialResult, done ->
                        launch(Dispatchers.Main) {
                            streamEventSink?.success(partialResult)
                            if (done) {
                                streamEventSink?.endOfStream()
                            }
                        }
                    }
                }
            } catch (e: Exception) {
                launch(Dispatchers.Main) {
                    streamEventSink?.error("INFERENCE_ERROR", "Failed to generate response: ${e.message}", null)
                }
            }
        }
    }

    private fun disposeLlm() {
        llmInference?.close()
        llmInference = null
    }

    override fun onDestroy() {
        super.onDestroy()
        disposeLlm()
        coroutineScope.cancel()
    }
}

