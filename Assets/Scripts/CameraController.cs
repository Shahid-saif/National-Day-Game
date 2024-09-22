using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraController : MonoBehaviour
{
    public Transform player;       // مرجع لموقع اللاعب
    public Vector3 offset;         // المسافة بين الكاميرا واللاعب
    public float followSpeed = 5f; // سرعة تتبع الكاميرا للاعب

    [Header("Camera Shake")]
    public Transform Camera;
    public float shakeDuration = 0.5f;  // مدة هزة الكاميرا
    public float shakeMagnitude = 0.3f; // قوة الهزة
    private Vector3 initialPosition;    // موقع الكاميرا الأصلي

    void Start()
    {
        // حفظ موقع الكاميرا الأصلي
        initialPosition = Camera.localPosition;
    }

    void LateUpdate()
    {
        // تتبع اللاعب بتحريك الكاميرا نحو اللاعب بمسافة offset
        Vector3 targetPosition = player.position + offset;
        transform.position = Vector3.Lerp(transform.position, targetPosition, followSpeed * Time.deltaTime);
    }

    // دالة لتشغيل هزة الكاميرا
    public void ShakeCamera()
    {
        StartCoroutine(Shake());
    }
    public void ShakeCamera(float shakeDuration, float shakeMagnitude)
    {
        StartCoroutine(Shake(shakeDuration,shakeMagnitude));
    }


    IEnumerator Shake()
    {
        float elapsedTime = 0f;

        // بينما المدة المتبقية للهزة أكبر من 0
        while (elapsedTime < shakeDuration)
        {
            // توليد حركة عشوائية حول الموقع الأصلي للكاميرا
            Vector3 randomOffset = Random.insideUnitSphere * shakeMagnitude;
            Camera.localPosition = initialPosition + randomOffset;

            elapsedTime += Time.deltaTime;

            yield return null; // الانتظار حتى الإطار التالي
        }

        // إعادة الكاميرا إلى الموقع الأصلي
        Camera.localPosition = initialPosition;
    }

    IEnumerator Shake(float shakeDuration, float shakeMagnitude)
    {
        float elapsedTime = 0f;

        // بينما المدة المتبقية للهزة أكبر من 0
        while (elapsedTime < shakeDuration)
        {
            // توليد حركة عشوائية حول الموقع الأصلي للكاميرا
            Vector3 randomOffset = Random.insideUnitSphere * shakeMagnitude;
            Camera.localPosition = initialPosition + randomOffset;

            elapsedTime += Time.deltaTime;

            yield return null; // الانتظار حتى الإطار التالي
        }

        // إعادة الكاميرا إلى الموقع الأصلي
        Camera.localPosition = initialPosition;
    }
}
