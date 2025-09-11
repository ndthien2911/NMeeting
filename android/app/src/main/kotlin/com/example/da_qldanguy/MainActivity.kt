package vn.vnpthcm.daihoidoan

import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugin.common.PluginRegistry.PluginRegistrantCallback
//import io.flutter.plugins.firebasemessaging.FlutterFirebaseMessagingService
//import io.flutter.plugins.firebasemessaging.FirebaseMessagingPlugin
import android.app.Activity
import android.content.Intent
import com.vnptit.idg.sdk.activity.VnptPortraitActivity
import com.vnptit.idg.sdk.utils.KeyIntentConstants.*
import com.vnptit.idg.sdk.utils.KeyResultConstants.PORTRAIT_FAR_IMAGE
import com.vnptit.idg.sdk.utils.SDKEnum
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import android.util.Log

class MainActivity: FlutterFragmentActivity()  {
    private val CHANNEL = "com.flutter.devekyc/callsdk"
    private var mResult: MethodChannel.Result? = null

    override
    fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        MethodChannel(
                flutterEngine!!.dartExecutor.binaryMessenger,
                CHANNEL
        ).setMethodCallHandler { call, result ->
            if (call.method == "getInformationCard") {
                openEKYC(call, result)
            } else {
                result.notImplemented()
            }
        }
//        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
//        .setMethodCallHandler((call, result) -> {
//        // Your existing code
//            }
//        );
    }

    private fun openEKYC(call: MethodCall, result: MethodChannel.Result) {
        mResult = result
        val activity: Activity = this
        if (activity == null) {
            result.error(
                    "ACTIVITY_NOT_AVAILABLE", "Browser cannot be opened " +
                    "without foreground activity", null
            )
            return
        }
        val intent: Intent = Intent(this, VnptPortraitActivity::class.java)
        intent.putExtra(CAMERA_FOR_PORTRAIT, SDKEnum.CameraTypeEnum.FRONT.getValue())
        intent.putExtra(VERSION_SDK, SDKEnum.VersionSDKEnum.ADVANCED.getValue())
        // lan dau la show, từ sau là k show nữa
        intent.putExtra(SHOW_DIALOG_SUPPORT, true)
        intent.putExtra(ENABLE_GOT_IT, true)
        intent.putExtra(CHANGE_LANGUAGE_IN_SDK, true)
        intent.putExtra(LANGUAGE, SDKEnum.LanguageEnum.VIETNAMESE.getValue())
        intent.putExtra(CHANGE_THEME, true)
        intent.putExtra(LOGO, "ic_oval_vnpt.png")
        startActivityIfNeeded(
                intent, 2
        )
    }


    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == 2) {
            if (resultCode == Activity.RESULT_OK) {
                val far_image_path = data!!.getStringExtra(PORTRAIT_FAR_IMAGE)

//                Log.e("EKYC", data.toUri(0))
                mResult!!.success(far_image_path)
            }
        }

    }
}
