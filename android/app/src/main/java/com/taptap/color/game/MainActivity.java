package com.taptap.color.game;

import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.net.Uri;
import android.os.AsyncTask;
import android.widget.Toast;

import androidx.annotation.NonNull;

import com.ljvpbsdiwc.adx.service.InterstitialAdsManager;
import com.ljvpbsdiwc.adx.service.LocalAdListener;
import com.taptap.color.game.utils.BackUpModel;
import com.taptap.color.game.utils.HttpHandler;


import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;
import java.util.Random;
import java.util.concurrent.ExecutionException;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugins.*;
import vn.aib.ratedialog.RatingDialog;

public class MainActivity extends FlutterActivity {

  private InterstitialAdsManager adsManager;
  private String TAG = MainActivity.class.getSimpleName();
  private BackUpModel backUpModel;
  public static String NATIVE_AD_ID = "ca-app-pub-3940256099942544/2247696110";
  public static String INTER_ID = "ca-app-pub-6065970673322847/2125972529";
  public static String BANNER_ID = "ca-app-pub-6065970673322847/4752135860";
  public static String REWARDED_ID = "ca-app-pub-6065970673322847/3649687621";
  public static int PERCENT_SHOW_BANNER_AD = 100;
  public static int PERCENT_SHOW_INTER_AD = 100;
  public static int PERCENT_SHOW_NATIVE_AD = 100;
  public static int PERCENT_SHOW_REWARDED_AD = 100;
  public static int NUMBER_OF_NATIVE_AD = 3;
  private static final String CHANNEL = "com.taptap.color";

  @Override
  public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
    GeneratedPluginRegistrant.registerWith(flutterEngine);

    try {
      Void aVoid = new GetBackUp().execute().get();
      if(backUpModel != null){
        if(!backUpModel.isLive){
          new AlertDialog.Builder(MainActivity.this)
                  .setTitle("Notice from developer")
                  .setMessage("Please update the new application to continue using it. We are really sorry for this issue.")
                  .setPositiveButton(android.R.string.yes, new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int which) {
                      showApp(MainActivity.this, backUpModel.newAppPackage);
                    }
                  })
                  .setNegativeButton(android.R.string.no, new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int which) {
                      dialog.cancel();
                    }
                  })
                  .setIcon(android.R.drawable.ic_dialog_alert)
                  .setCancelable(false)
                  .show();
        }
      }
    } catch (ExecutionException e) {
      e.printStackTrace();
    } catch (InterruptedException e) {
      e.printStackTrace();
    } catch (Exception e) {
      e.printStackTrace();
    }

//    adsManager = new InterstitialAdsManager();
//    adsManager.init(true, this, INTER_ID, "#000000", getString(R.string.app_name));

    SharedPreferences prefs = getSharedPreferences("rate_dialog", MODE_PRIVATE);
    Boolean rated = prefs.getBoolean("rate", false);
    if(!rated){
      showRateDialog();
    }

    new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), CHANNEL).setMethodCallHandler(
            new MethodCallHandler() {
              @Override
              public void onMethodCall(MethodCall call, Result result) {
                {
                  switch(call.method){

                    case "showInter":
                      Random r = new Random();
                      int ads = r.nextInt(100);

                      if (ads < PERCENT_SHOW_INTER_AD){
                        adsManager.showAd(new LocalAdListener() {
                          @Override
                          public void onAdFailedToLoad() {
                            if(! isOnline()){
                              Toast.makeText(MainActivity.this, "Check your network connection status.", Toast.LENGTH_SHORT).show();
                            }
                          }
                          @Override
                          public void onAdClosed() {
//
                          }
                        });
                      }
                      break;

                    case "getRewardedID":
                      Random ra = new Random();
                      int ad = ra.nextInt(100);
                      if(ad < PERCENT_SHOW_REWARDED_AD){
                        result.success(REWARDED_ID);
                      } else {
                        result.success("ca-app-pub-3940256099942544/5224354917");
                      }
                      break;

                    case "rate":
                      rateApp(MainActivity.this);
                      break;
                    case "moreApp":
                      moreApp(MainActivity.this);
                      break;

                  }

                }
              }
            });
  }

  public boolean isOnline() {
    Runtime runtime = Runtime.getRuntime();
    try {
      Process ipProcess = runtime.exec("/system/bin/ping -c 1 8.8.8.8");
      int     exitValue = ipProcess.waitFor();
      return (exitValue == 0);
    }
    catch (IOException e)          { e.printStackTrace(); }
    catch (InterruptedException e) { e.printStackTrace(); }

    return false;
  }

  private void showRateDialog() {
    RatingDialog ratingDialog = new RatingDialog(this);
    ratingDialog.setRatingDialogListener(new RatingDialog.RatingDialogInterFace() {
      @Override
      public void onDismiss() {
      }

      @Override
      public void onSubmit(float rating) {
        rateApp(MainActivity.this);
        SharedPreferences.Editor editor = getSharedPreferences("rate_dialog", MODE_PRIVATE).edit();
        editor.putBoolean("rate", true);
        editor.commit();
      }

      @Override
      public void onRatingChanged(float rating) {
      }
    });
    ratingDialog.showDialog();
  }

  public static void rateApp(Context context) {
    Intent intent = new Intent(new Intent(Intent.ACTION_VIEW,
            Uri.parse("http://play.google.com/store/apps/details?id=" + context.getPackageName())));
    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TOP);
    intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
    context.startActivity(intent);
  }

  public static void showApp(Context context, String pkg) {
    Intent intent = new Intent(new Intent(Intent.ACTION_VIEW,
            Uri.parse("http://play.google.com/store/apps/details?id=" + pkg)));
    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TOP);
    intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
    context.startActivity(intent);
  }

  public static void moreApp(Context context) {
    Intent intent = new Intent(new Intent(Intent.ACTION_VIEW,
            Uri.parse("https://play.google.com/store/apps/developer?id=LuckyyStore")));
    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TOP);
    intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
    context.startActivity(intent);
  }

  private class GetBackUp extends AsyncTask<Void, Void, Void> {
    @Override
    protected void onPreExecute() {
      super.onPreExecute();

    }

    @Override
    protected Void doInBackground(Void... arg0) {
      HttpHandler sh = new HttpHandler();
      // Making a request to url and getting response
      String url = "https://raw.githubusercontent.com/toolshapnga/taptap_color/master/backupdata.json";
      String jsonStr = sh.makeServiceCall(url);

      if (jsonStr != null) {
        try {
          JSONObject jsonObj = new JSONObject(jsonStr);
          String appPackage = jsonObj.getString("appPackage");
          Boolean isLive = jsonObj.getBoolean("isLive");
          String newAppPackage = jsonObj.getString("newAppPackage");
          Boolean isAdsShow = jsonObj.getBoolean("isAdsShow");
          String inter = jsonObj.getString("inter");
          String fb_inter = jsonObj.getString("fb_inter");
          Boolean isShowGG = jsonObj.getBoolean("isShowGG");
          String banner = jsonObj.getString("banner");
          String nativeAd = jsonObj.getString("nativeAd");
          String rewarded = jsonObj.getString("rewarded");
          int percent_banner = jsonObj.getInt("percent_banner");
          int percent_inter = jsonObj.getInt("percent_inter");
          int percent_native = jsonObj.getInt("percent_native");
          int percent_rewarded = jsonObj.getInt("percent_rewarded");
          int numberNativeAd = jsonObj.getInt("numberNativeAd");

          backUpModel = new BackUpModel();
          backUpModel.appPackage = appPackage;
          backUpModel.isLive = isLive;
          backUpModel.newAppPackage = newAppPackage;
          backUpModel.isAdsShow = isAdsShow;
          backUpModel.inter = inter;
          backUpModel.fb_inter = fb_inter;
          backUpModel.isShowGG = isShowGG;
          backUpModel.banner = banner;
          backUpModel.nativeAd = nativeAd;
          backUpModel.rewarded = rewarded;
          backUpModel.percent_banner = percent_banner;
          backUpModel.percent_inter = percent_inter;
          backUpModel.percent_native = percent_native;
          backUpModel.numberNativeAd = numberNativeAd;
          backUpModel.percent_rewarded = percent_rewarded;

          MainActivity.INTER_ID =backUpModel.inter;
          MainActivity.NATIVE_AD_ID =backUpModel.nativeAd;
          MainActivity.BANNER_ID =backUpModel.banner;
          MainActivity.PERCENT_SHOW_BANNER_AD =backUpModel.percent_banner;
          MainActivity.PERCENT_SHOW_INTER_AD =backUpModel.percent_inter;
          MainActivity.PERCENT_SHOW_NATIVE_AD =backUpModel.percent_native;
          MainActivity.NUMBER_OF_NATIVE_AD =backUpModel.numberNativeAd;
          MainActivity.REWARDED_ID = backUpModel.rewarded;
          MainActivity.PERCENT_SHOW_REWARDED_AD = backUpModel.percent_rewarded;

        } catch (final JSONException e) {
          runOnUiThread(new Runnable() {
            @Override
            public void run() {

            }
          });

        }

      } else {
        runOnUiThread(new Runnable() {
          @Override
          public void run() {

          }
        });
      }

      return null;
    }

    @Override
    protected void onPostExecute(Void result) {
      super.onPostExecute(result);
    }
  }

  @Override
  protected void onResume() {
    super.onResume();
//    if (adsManager != null)
//      adsManager.onResume();
  }
}
