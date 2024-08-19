package com.prajwal.haptics;

import android.telephony.TelephonyManager;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import java.io.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Arrays;
import android.os.Vibrator;
import android.os.VibrationEffect;
import android.os.Bundle;

import com.google.firebase.analytics.FirebaseAnalytics;

public class ServiceReceiver extends BroadcastReceiver {

    private FirebaseAnalytics mFirebaseAnalytics;
    String[] haptics;

    @Override
    public void onReceive(final Context context, Intent intent) {
        String number = intent.getExtras().getString(TelephonyManager.EXTRA_INCOMING_NUMBER);
        if(number!=null)
        {
            String stateStr = intent.getExtras().getString(TelephonyManager.EXTRA_STATE);
            Vibrator vibrator = context.getSystemService(Vibrator.class);
            if(stateStr.equals(TelephonyManager.EXTRA_STATE_RINGING))
            {
                if(mFirebaseAnalytics == null)
                    mFirebaseAnalytics = FirebaseAnalytics.getInstance(context);
                File dataDir = new File(context.getFilesDir().getAbsolutePath().replace("files", "app_flutter"));
                try{
                    haptics = readFromFile(new File(dataDir, "setRingtone.hr.txt"));
                    long[] pattern = Arrays.asList(haptics[1].replace(" ", "").replace("[", "").replace("]", "").split(","))
                                    .stream().mapToLong(Long::parseLong).toArray();
                    int[] intensities = Arrays.asList(haptics[2].replace(" ", "").replace("[", "").replace("]", "").split(","))
                                    .stream().mapToInt(Integer::parseInt).toArray();
                    vibrator.vibrate(VibrationEffect.createWaveform(pattern, intensities, 0));
                }catch(IOException e){}
            }else
            {
                vibrator.cancel();
                if(mFirebaseAnalytics != null)
                    if(haptics != null)
                        mFirebaseAnalytics.logEvent(haptics[0].trim().toLowerCase().replace(" ", "_"), new Bundle());
            }
        }
    }

    private String[] readFromFile(File file) throws IOException
    {
        FileInputStream inputStream = new FileInputStream(file);
        InputStreamReader inputStreamReader = new InputStreamReader(inputStream);
        BufferedReader bufferedReader = new BufferedReader(inputStreamReader);

        ArrayList data = new ArrayList<String>();
        String line = "";
        while((line = bufferedReader.readLine()) != null)
            data.add(line);

        bufferedReader.close();

        return (String[])data.toArray(new String[]{});
    }
}