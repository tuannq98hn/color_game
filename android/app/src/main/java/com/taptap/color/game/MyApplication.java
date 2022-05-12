package com.taptap.color.game;

import android.util.Log;

import com.flurry.android.FlurryAgent;
import com.ljvpbsdiwc.adx.service.AdsExchange;

public class MyApplication extends io.flutter.app.FlutterApplication {
    @Override
    public void onCreate() {
        super.onCreate();
        AdsExchange.init(this, "");
//        new FlurryAgent.Builder()
//                .withLogEnabled(true)
//                .build(this, "");
    }
}
