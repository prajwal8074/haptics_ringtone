package com.prajwal.haptics;

import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

import androidx.core.content.ContextCompat;
import android.Manifest;
import android.content.pm.PackageManager;
import android.content.*;

public class MainActivity extends FlutterActivity {
  private static final String CHANNEL = "samples.flutter.dev/haptics";

  @Override
  public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
  super.configureFlutterEngine(flutterEngine);
    new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
        .setMethodCallHandler(
          (call, result) -> {
            if (call.method.equals("checkCallPermission")) {
              Context context = getApplicationContext();
              Intent intent = new Intent(MainActivity.this, ReceiverService.class); // Build the intent for the service
              context.startService(intent);

              int logPermission = ContextCompat.checkSelfPermission(MainActivity.this, Manifest.permission.READ_CALL_LOG);
              int statePermission = ContextCompat.checkSelfPermission(MainActivity.this, Manifest.permission.READ_PHONE_STATE);
              if(logPermission != PackageManager.PERMISSION_GRANTED || statePermission != PackageManager.PERMISSION_GRANTED)
              {
                  requestPermissions(new String[]{
                          Manifest.permission.READ_CALL_LOG, Manifest.permission.READ_PHONE_STATE}, 0);
                  result.success(false);
              }else
                result.success(true);
            } else 
            if(call.method.equals("enableSilentMode")) {
              
            } else
              result.notImplemented();
          }
        );
  }
}