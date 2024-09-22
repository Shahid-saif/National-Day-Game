using System.Collections;
using System.Collections.Generic;
using Unity.Mathematics;
using UnityEngine;
using UnityEngine.Splines;

public class PlayerFollowSpline : MonoBehaviour
{
    public SplineContainer currentSpline;  // SplineContainer الذي يتبعه اللاعب حالياً
    public float speed = 5f;               // سرعة اللاعب
    public float rotationSpeed = 5f;       // سرعة دوران اللاعب
    private float distanceAlongSpline = 0f; // المسافة التي قطعها اللاعب على الـ Spline
    [SerializeField] int CurrSplinePointIndex;
    void Start()
    {
        // تعيين موقع اللاعب عند بداية اللعبة إلى أول نقطة في الـ Spline
        if (currentSpline != null)
        {
            Vector3 startPosition = SplineUtility.EvaluatePosition(currentSpline.Spline, 0f);
            transform.position = startPosition;
            distanceAlongSpline = 0f;
        }
    }

    void Update()
    {
        if (currentSpline != null)
        {
            // الوصول إلى الـ Spline داخل الـ SplineContainer
            var spline = currentSpline.Spline;

            if (Vector3.Distance(transform.position, spline[CurrSplinePointIndex].Position) < 0.2f)
            {
                CurrSplinePointIndex++;
                if (CurrSplinePointIndex >= spline.Count)
                {
                    SwitchToNextSpline();
                    CurrSplinePointIndex = 0;
                }
            }

            transform.position = Vector3.MoveTowards(transform.position, spline[CurrSplinePointIndex].Position, speed);
            transform.rotation = Quaternion.RotateTowards(transform.rotation, spline[CurrSplinePointIndex].Rotation, rotationSpeed * Time.deltaTime);

            //// الحصول على طول الـ Spline
            //float splineLength = SplineUtility.CalculateLength(spline, float4x4.identity);

            //// تحديث موضع اللاعب على الـ Spline بناءً على السرعة
            //distanceAlongSpline += speed * Time.deltaTime;

            //// إذا وصل اللاعب إلى نهاية الـ Spline الحالي، انتقل إلى Spline جديد
            //if (distanceAlongSpline >= splineLength)
            //{
            //    SwitchToNextSpline();
            //}
            //float normalizedDistance = distanceAlongSpline / splineLength;
            //// احصل على موضع اللاعب على الـ Spline
            //Vector3 newPosition = SplineUtility.EvaluatePosition(spline, normalizedDistance);

            //// احصل على ارتفاع الـ Spline عند موقع اللاعب
            //float splineHeight = newPosition.y; // احفظ الارتفاع

            //// قم بتحديث موقع اللاعب بحيث يتطابق مع ارتفاع الـ Spline
            //transform.position = new Vector3(newPosition.x, splineHeight, newPosition.z);

            ////// الحصول على الاتجاه الأمامي (التانجنت) على الـ Spline
            //Vector3 forwardDirection = SplineUtility.EvaluateTangent(spline, normalizedDistance);

            //// تأكد من أن الاتجاه الأمامي ليس صفريًا
            //if (forwardDirection.magnitude > 0)
            //{
            //    forwardDirection.Normalize();
            //}
            //else
            //{
            //    forwardDirection = Vector3.forward; // استخدم قيمة افتراضية
            //}

            //// تحديث التدوير بناءً على الاتجاه الأمامي فقط
            //Quaternion targetRotation = Quaternion.LookRotation(forwardDirection);
            //transform.rotation = Quaternion.RotateTowards(transform.rotation, targetRotation, rotationSpeed * Time.deltaTime);
        }
    }

    // دالة لتغيير الـ Spline الحالي إلى Spline جديد
    void SwitchToNextSpline()
    {
        // ابحث عن Spline جديد هنا، على سبيل المثال قد يتم تخزينه في قائمة أو توليده أثناء اللعب
        SplineContainer nextSpline = FindNextSpline();

        if (nextSpline != null)
        {
            // تحديث الـ Spline الحالي والبدء من البداية
            currentSpline = nextSpline;
            distanceAlongSpline = 0f;
        }
    }

    // دالة لبحث أو توليد الـ Spline الجديد
    SplineContainer FindNextSpline()
    {

        // من هنا يمكنك وضع منطق لتحديد الـ Spline الجديد أو توليده ديناميكياً
        return SplineManager.Instance.GetNextSpline();
    }
}
