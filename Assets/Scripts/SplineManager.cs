using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Splines;

public class SplineManager : MonoBehaviour
{
    public List<SplineContainer> AllSplines = new List<SplineContainer>();
    public List<SplineContainer> activeSplines = new List<SplineContainer>();
    private int currentSplineIndex = 0;

    public static SplineManager Instance { get; private set; }

    void Awake()
    {
        if (Instance == null)
        {
            Instance = this;
        }
        else
        {
            Destroy(gameObject);
        }
    }

    // دالة لإضافة Spline إلى القائمة
    public void AddSpline(SplineContainer splineContainer)
    {
        activeSplines.Add(splineContainer);
    }

    // دالة لحذف Spline من القائمة
    public void RemoveSpline(SplineContainer splineContainer)
    {
        if (activeSplines.Contains(splineContainer))
        {
            activeSplines.Remove(splineContainer);
        }
    }

    // دالة لاستبدال Spline الحالي بـ Spline جديد
    public SplineContainer GetNextSpline()
    {
        if (activeSplines.Count == 0)
        {
            Debug.LogError("لا يوجد Splines متاحة.");
            return null;
        }

        currentSplineIndex = (currentSplineIndex + 1) % activeSplines.Count;
        return activeSplines[currentSplineIndex];
    }

    // دالة لربط نهاية Spline الحالي ببداية Spline جديد
    public void ConnectSplines(SplineContainer currentSpline, SplineContainer nextSpline)
    {
        if (currentSpline == null || nextSpline == null)
        {
            Debug.LogError("يجب تمرير Splines صحيحة.");
            return;
        }

        var currentSplineData = currentSpline.Spline;
        var nextSplineData = nextSpline.Spline;

        if (currentSplineData.Count == 0 || nextSplineData.Count == 0)
        {
            Debug.LogError("لا توجد عقد في أحد الـ Splines.");
            return;
        }

        // احصل على آخر عقدة من الـ Spline الحالي
        var lastKnot = currentSplineData[currentSplineData.Count - 1];

        // تأكد من أن هناك مساحة لإضافة عقدة جديدة
        if (nextSplineData.Count > 0)
        {
            // قم بتعديل إحداثيات أول عقدة في الـ Spline التالي
            nextSplineData[0] = lastKnot; // تعديل مباشرة
        }
        else
        {
            // إذا لم يكن هناك عقد، أضف العقدة الجديدة
            nextSplineData.Add(lastKnot); // أضف العقدة الجديدة
        }
    }

    // دالة لجلب الـ Spline الحالي
    public SplineContainer GetCurrentSpline()
    {
        if (activeSplines.Count == 0)
        {
            Debug.LogError("لا يوجد Splines متاحة.");
            return null;
        }

        return activeSplines[currentSplineIndex];
    }
}
