package com.prajwal.haptics;

import android.content.IntentFilter;
import android.app.*;
import android.content.*;
import android.os.*;
import androidx.core.app.*;
import android.content.pm.ServiceInfo;
import android.content.BroadcastReceiver;

public class ReceiverService extends Service {
    BroadcastReceiver broadcastReceiver;

    @Override
	public int onStartCommand(Intent intent, int flags, final int startId)
	{
		NotificationCompat.Builder notification =
                new NotificationCompat.Builder(this, "Call Receiver")
					.setSmallIcon(R.drawable.ic_logo_transparent)
					.setContentIntent(PendingIntent.getActivity(ReceiverService.this, 0, 
						new Intent(this, MainActivity.class), PendingIntent.FLAG_MUTABLE))
					.setStyle(new NotificationCompat.BigTextStyle()
                		.bigText("receiving calls"));
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
		{
			String CHANNEL_ID = getPackageName().replace(".", "_");// The id of the channel. 
			notification.setChannelId(CHANNEL_ID);
			NotificationChannel mChannel = new NotificationChannel(CHANNEL_ID, "Call Receiver Notification", NotificationManager.IMPORTANCE_LOW);	
			NotificationManager mNotificationManager =
				(NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
			mNotificationManager.createNotificationChannel(mChannel);
		}
        int type = 0;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            type = ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE;
        }
        ServiceCompat.startForeground(this, 69420, notification.build(), type);

        // create IntentFilter
        IntentFilter intentFilter = new IntentFilter();

        //add actions 
        intentFilter .addAction("android.intent.action.PHONE_STATE");

        //create and register receiver
        broadcastReceiver = new ServiceReceiver();
        registerReceiver(broadcastReceiver, intentFilter);

        return super.onStartCommand(intent, flags, startId);
    }

	@Override
	public IBinder onBind(Intent intent)
	{
		// TODO: Implement this method
		return onBind(intent);
	}
}