package com.seolo.seolo.presentation

import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.drawable.Drawable
import android.os.Build
import android.os.Bundle
import android.util.Log
import androidx.annotation.RequiresApi
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat
import com.bumptech.glide.Glide
import com.seolo.seolo.R
import com.seolo.seolo.adapters.BluetoothAdapter
import com.seolo.seolo.databinding.BluetoothLayoutBinding

class BluetoothActivity : AppCompatActivity() {
    private lateinit var binding: BluetoothLayoutBinding
    private lateinit var bluetoothAdapter: BluetoothAdapter

    // 액티비티 생성 시
    @RequiresApi(Build.VERSION_CODES.S)
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // 테마 설정
        setTheme(android.R.style.Theme_DeviceDefault)

        // 액션바 숨기기
        supportActionBar?.hide()

        // View Binding 초기화
        binding = BluetoothLayoutBinding.inflate(layoutInflater)
        setContentView(binding.root)

        // Glide를 사용하여 GIF 이미지 로딩
        Glide.with(this).asGif().load(R.drawable.bluetooth).into(binding.bluetoothView)

        // ImageView에 일반 이미지 로딩
        val drawable: Drawable? = ContextCompat.getDrawable(this, R.drawable.img_nfc)
        binding.bluetoothView.setImageDrawable(drawable)

        bluetoothAdapter = BluetoothAdapter(this)

        checkBluetoothPermissions()

        sendConnectionCheckMessage()

    }

    @RequiresApi(Build.VERSION_CODES.S)
    private fun checkBluetoothPermissions() {
        if (bluetoothAdapter.isBluetoothEnabled()) {
            bluetoothAdapter.startDiscovery()
        } else {
            bluetoothAdapter.createEnableBluetoothIntent()?.let {
                startActivityForResult(it, bluetoothAdapter.REQUEST_ENABLE_BT)
            }
        }
    }

    @RequiresApi(Build.VERSION_CODES.S)
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == bluetoothAdapter.REQUEST_ENABLE_BT && resultCode == RESULT_OK) {
            bluetoothAdapter.startDiscovery()
        }
    }

    @RequiresApi(Build.VERSION_CODES.S)
    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == bluetoothAdapter.REQUEST_BLUETOOTH_SCAN && grantResults.all { it == PackageManager.PERMISSION_GRANTED }) {
            bluetoothAdapter.startDiscoveryWithPermissions()
        } else {
            Log.e("BluetoothActivity", "Required permissions not granted.") // 권한 요청 거부 처리
        }
    }

    private fun sendConnectionCheckMessage() {
        val message = "연결확인".toByteArray()
        Log.d("BluetoothActivity", "Sending connection check message to the device.")
    }


    // 액티비티 종료 시
    override fun onDestroy() {
        super.onDestroy()
        bluetoothAdapter.cleanup() // 리시버 등록 해제
    }
}
