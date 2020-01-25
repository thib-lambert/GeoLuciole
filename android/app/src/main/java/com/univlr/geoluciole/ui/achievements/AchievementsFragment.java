package com.univlr.geoluciole.ui.achievements;

import android.content.Context;
import android.graphics.Point;
import android.os.Bundle;
import android.util.Log;
import android.view.Display;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ScrollView;
import android.widget.TableLayout;
import android.widget.TableRow;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.constraintlayout.widget.ConstraintLayout;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentManager;
import androidx.fragment.app.FragmentTransaction;
import androidx.lifecycle.ViewModelProviders;

import com.univlr.geoluciole.MainActivity;
import com.univlr.geoluciole.R;
import com.univlr.geoluciole.adapter.ViewPagerAdapter;
import com.univlr.geoluciole.model.UserPreferences;
import com.univlr.geoluciole.model.badge.BadgeManager;

/**
 * classe AchievementsFragment correspondant à la vue des badges
 */
public class AchievementsFragment extends Fragment {
    private static final String TAG = AchievementsFragment.class.getSimpleName();
    private static final int NB_BADGE_PER_ROW = 3;
    private static final int IMG_WIDTH = 250;
    private static final int IMG_HEIGHT = 250;
    private static final int MARGIN = 30;
    private static final int PADDING = 40;
    private AchievementsViewModel achievementsViewModel;
    private MainActivity context;

    public View onCreateView(@NonNull LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        this.achievementsViewModel = ViewModelProviders.of(this).get(AchievementsViewModel.class);
        View root = inflater.inflate(R.layout.fragment_achievements, container, false);
        this.context = (MainActivity) root.getContext();
        TableLayout mTableLayout = (TableLayout) root.findViewById(R.id.table_badges);
        // get instance des preferences user
        UserPreferences userPref = UserPreferences.getInstance(root.getContext());
        // si liste vide, vue sans badges
        if (userPref.getListUnlockedBadges().isEmpty()) {
            ScrollView scrollView = (ScrollView) root.findViewById(R.id.scroll_badges);
            scrollView.setVisibility(View.INVISIBLE);
        } else { // cache la vue scroll si aucun badge debloque
            ConstraintLayout constraintLayout = root.findViewById(R.id.layout_sticker);
            constraintLayout.setVisibility(View.INVISIBLE);
            // layout de la table
            LinearLayout.LayoutParams tableRowParams = new LinearLayout.LayoutParams(
                    LinearLayout.LayoutParams.MATCH_PARENT,
                    LinearLayout.LayoutParams.MATCH_PARENT);

            // init de la premiere row
            TableRow row = new TableRow(root.getContext());
            // pour chaque badge debloqués dans la liste
            for (int j = 0; j < userPref.getListUnlockedBadges().size(); ++j) {
                // pour afficher 3 badges par row
                if (j % NB_BADGE_PER_ROW == 0 && j != 0) {
                    row = new TableRow(root.getContext());
                }
                row.setLayoutParams(tableRowParams);
                // instanciation d'une image view
                ImageView iv = setImage(root, userPref, j);
                // ajout de l'image a la row
                row.addView(iv);
                // ajout de la row a la table
                if (j % NB_BADGE_PER_ROW == 0) {
                    mTableLayout.addView(row);
                }
            }
        }
        return root;
    }

    private ImageView setImage(View root, UserPreferences userPref, int j) {
        ImageView iv = new ImageView(root.getContext());
        // compute width - height
        WindowManager wm = (WindowManager) context.getSystemService(Context.WINDOW_SERVICE);
        Display display = wm.getDefaultDisplay();
        Point size = new Point();
        display.getSize(size);
        int paddingSpace = PADDING * (NB_BADGE_PER_ROW + 1);
        int widthPerItem = (size.x - paddingSpace) / NB_BADGE_PER_ROW;
       // int heightPerItem = (size.y - paddingSpace) / NB_BADGE_PER_ROW;

        // set ressource
        iv.setImageResource(getRessourceImageBadge(userPref.getListUnlockedBadges().get(j)));
        TableRow.LayoutParams layoutParams = new TableRow.LayoutParams(widthPerItem, ViewGroup.LayoutParams.WRAP_CONTENT);

        // layoutParams.setMargins(MARGIN, MARGIN, MARGIN, MARGIN);
        iv.setPadding(PADDING, PADDING, PADDING, PADDING);
        iv.setLayoutParams(layoutParams);
        iv.setClickable(true);
        iv.bringToFront();
        iv.setAdjustViewBounds(true);
        //iv.setScaleType(ImageView.ScaleType.FIT_CENTER);
        iv.setOnClickListener(getBadgeInfo(userPref.getListUnlockedBadges().get(j), root.getContext()));
        Log.i(TAG, "setImage, création de l'image - id :" + userPref.getListUnlockedBadges().get(j));
        return iv;
    }


    private View.OnClickListener getBadgeInfo(final String idBadge, final Context context) {
        return new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                BadgeManager badgeManager = BadgeManager.getInstance(context);
                if (badgeManager.getArrayBadges().containsKey(idBadge)) {
                    String name = badgeManager.getArrayBadges().get(idBadge).getName();
                    String desc = badgeManager.getArrayBadges().get(idBadge).getDescription();
                    Toast.makeText(view.getContext(),
                            "Badge " + name + " \n" + desc
                            , Toast.LENGTH_SHORT).show();
                }
            }
        };
    }

    /**
     * Méthode permettant de récupérer les ressources des images des badges
     * correspondant à un id donné passé en paramètre
     *
     * @param idBadge String id correspondant à un badge
     * @return int reférence vers l'image
     */
    public static int getRessourceImageBadge(String idBadge) {
        switch (idBadge) {
            case "0":
                return R.mipmap.badge_1km;
            case "1":
                return R.mipmap.badge_5km;
            case "2":
                return R.mipmap.badge_10km;
            case "3":
                return R.mipmap.badge_saint_nicolas;
            case "4":
                return R.mipmap.badge_tour_chaine;
            case "5":
                return R.mipmap.badge_tour_lanterne;
            case "6":
                return R.mipmap.badge_eglise_st_sauveur;
            case "7":
                return R.mipmap.badge_grosse_horloge;
            case "8":
                return R.mipmap.no_image;
            case "9":
                return R.mipmap.no_image;
            case "10":
                return R.mipmap.no_image;
            case "11":
                return R.mipmap.no_image;
            default:
                return R.mipmap.no_image;
        }
    }

}