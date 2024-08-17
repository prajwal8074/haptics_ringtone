package com.prajwal.haptics;

import android.content.Intent;
import android.content.BroadcastReceiver;
import android.content.*;

public class BootReceiver extends BroadcastReceiver
{
    @Override
    public void onReceive(final Context context, Intent intent) {
    	Intent intentStart = new Intent(context, ReceiverService.class);
    	context.startForegroundService(intentStart);
    }
}