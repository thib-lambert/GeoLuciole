package com.univlr.geoluciole.ui.home;

import android.content.Intent;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.animation.Animation;
import android.view.animation.Transformation;
import android.widget.CompoundButton;
import android.widget.ProgressBar;
import android.widget.Switch;

import androidx.annotation.NonNull;
import androidx.fragment.app.Fragment;

import com.univlr.geoluciole.MainActivity;
import com.univlr.geoluciole.R;
import com.univlr.geoluciole.location.LocationUpdatesService;
import com.univlr.geoluciole.model.UserPreferences;

import java.util.Calendar;


public class HomeFragment extends Fragment {

    private ProgressBar progressBar;
    private View root;

    public View onCreateView(@NonNull LayoutInflater inflater,
            ViewGroup container, Bundle savedInstanceState) {
         root = inflater.inflate(R.layout.fragment_home, container, false);

        progressBar = root.findViewById(R.id.progressBar_stay_progression);

        final Switch switchData = root.findViewById(R.id.data_collection_switch);
        updateSwitch(null);
        switchData.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                UserPreferences userPreferences = UserPreferences.getInstance(root.getContext());
                userPreferences.setSendData(isChecked);
                userPreferences.store(root.getContext());
                //updateSwitch(null);
            }
        });


        updateProgressBar();
        return root;
    }

    public void updateProgressBar() {
        UserPreferences userPreferences = UserPreferences.getInstance(root.getContext());
        int from = progressBar.getProgress();
        int to = calculProgress(userPreferences);
        ProgressBarAnimation anim = new ProgressBarAnimation(progressBar, from, to);
        anim.setDuration(1000);
        progressBar.startAnimation(anim);
    }

    public void updateSwitch(LocationUpdatesService mService) {

        UserPreferences userPreferences = UserPreferences.getInstance(root.getContext());
        Switch switchData = root.findViewById(R.id.data_collection_switch);

        //set du switch en fonction des données stockées
        switchData.setChecked(userPreferences.isSendData());


        // dans tous les cas si la periode de validité est depassé on coupe la collect
        Calendar current = Calendar.getInstance();
        if (userPreferences.getEndValidity() < current.getTimeInMillis()){
            userPreferences.setSendData(false);
            switchData.setChecked(false);
        }

        // TODO : work manager
        if(mService != null){
            if(!UserPreferences.getInstance(root.getContext()).isSendData()){
                mService.removeLocationUpdates();
            } else {
                mService.startService(new Intent(root.getContext(), LocationUpdatesService.class));

            }
        }

    }

    private int calculProgress(UserPreferences userPreferences) {
        Calendar calendar = Calendar.getInstance();
        long start = userPreferences.getStartValidity();
        long end = userPreferences.getEndValidity();
        if (start == 0 || end == 0) {
            return 0;
        }
        double x = (calendar.getTimeInMillis() - start);
        double y = (end - start);
        double res = x / y;
        return (int) (res *100);
    }
}

class ProgressBarAnimation extends Animation {
    private ProgressBar progressBar;
    private float from;
    private float  to;

    public ProgressBarAnimation(ProgressBar progressBar, float from, float to) {
        super();
        this.progressBar = progressBar;
        this.from = from;
        this.to = to;
    }

    @Override
    protected void applyTransformation(float interpolatedTime, Transformation t) {
        super.applyTransformation(interpolatedTime, t);
        float value = from + (to - from) * interpolatedTime;
        progressBar.setProgress((int) value);
    }

}