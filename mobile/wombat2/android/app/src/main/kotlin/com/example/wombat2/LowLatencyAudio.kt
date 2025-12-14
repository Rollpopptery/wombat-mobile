package com.example.wombat2

import android.media.AudioAttributes
import android.media.AudioFormat
import android.media.AudioTrack
import kotlin.math.sin
import kotlin.math.PI

class LowLatencyAudio {
    private var audioTrack: AudioTrack? = null
    private var isPlaying = false
    private var targetFrequency = 1000.0
    private var currentFrequency = 1000.0
    private var targetVolume = 0.5f
    private var currentVolume = 0.5f
    
    private val sampleRate = 44100
    private val bufferSize = AudioTrack.getMinBufferSize(
        sampleRate,
        AudioFormat.CHANNEL_OUT_MONO,
        AudioFormat.ENCODING_PCM_16BIT
    )
    
    private var generatorThread: Thread? = null
    
    fun init() {
        val audioAttributes = AudioAttributes.Builder()
            .setUsage(AudioAttributes.USAGE_MEDIA)
            .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
            .build()
        
        val audioFormat = AudioFormat.Builder()
            .setSampleRate(sampleRate)
            .setEncoding(AudioFormat.ENCODING_PCM_16BIT)
            .setChannelMask(AudioFormat.CHANNEL_OUT_MONO)
            .build()
        
        audioTrack = AudioTrack.Builder()
            .setAudioAttributes(audioAttributes)
            .setAudioFormat(audioFormat)
            .setBufferSizeInBytes(bufferSize)
            .setTransferMode(AudioTrack.MODE_STREAM)
            .build()
    }
    
    fun start() {
        if (isPlaying) return
        isPlaying = true
        currentFrequency = targetFrequency
        currentVolume = targetVolume
        audioTrack?.play()
        
        generatorThread = Thread {
            val buffer = ShortArray(bufferSize / 2)
            var phase = 0.0
            
            while (isPlaying) {
                // Smooth interpolation towards target values
                val freqSmoothingFactor = 0.3f
                val volSmoothingFactor = 0.4f
                
                currentFrequency += (targetFrequency - currentFrequency) * freqSmoothingFactor
                currentVolume += (targetVolume - currentVolume) * volSmoothingFactor
                
                for (i in buffer.indices) {
                    buffer[i] = (sin(phase) * 32767 * currentVolume).toInt().toShort()
                    phase += 2.0 * PI * currentFrequency / sampleRate
                    if (phase > 2.0 * PI) phase -= 2.0 * PI
                }
                
                audioTrack?.write(buffer, 0, buffer.size)
            }
        }
        generatorThread?.start()
    }
    
    fun stop() {
        isPlaying = false
        generatorThread?.join()
        audioTrack?.stop()
    }
    
    fun setFrequency(freq: Double) {
        targetFrequency = freq
    }
    
    fun setVolume(vol: Float) {
        targetVolume = vol.coerceIn(0f, 1f)
    }
    
    fun release() {
        stop()
        audioTrack?.release()
    }
}
