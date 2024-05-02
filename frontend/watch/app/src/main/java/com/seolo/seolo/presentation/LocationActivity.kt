package com.seolo.seolo.presentation

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import com.seolo.seolo.R
import com.seolo.seolo.adapters.LocationAdapter
import sh.tyy.wheelpicker.core.WheelPickerRecyclerView

class LocationActivity : AppCompatActivity() {
    private val locations = listOf("서울", "부산", "인천", "대구", "광주", "대전", "울산", "세종")
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        supportActionBar?.hide()

        setContentView(R.layout.location_layout)


        val locationPicker = findViewById<WheelPickerRecyclerView>(R.id.location_view)
        val locationAdapter = LocationAdapter(locations)
        locationPicker.adapter = locationAdapter

    }

}
