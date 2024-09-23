using System.Collections;
using System.Collections.Generic;
using System.Runtime.InteropServices.WindowsRuntime;
using TMPro;
using UnityEngine;
using UnityEngine.AdaptivePerformance.Provider;
using static UnityEngine.GraphicsBuffer;

public class PlayerController : MonoBehaviour
{
    [Header("Movement")]
    [SerializeField] float horizontalSpeed = 2f;

    [Header("Movement-Horizontal")]
    [SerializeField] Transform LeftPos;
    [SerializeField] Transform RightPos;
    [SerializeField] Transform MiddlePos;
    [SerializeField] Transform CurrPos;

    [Header("Movement-Forward")]
    [SerializeField] float RunSpeed;
    [SerializeField] Transform PlayerPos;
    [Header("Movement-Stats")]
    [SerializeField] bool isGrounded;
    [SerializeField] LayerMask Ground;
    [SerializeField] float groundSensorDistance = 10f;
    [SerializeField] Transform groundSensorTrans;
    [Header("Movement-Jump And slide")]
    [SerializeField] Animator playerAnim;
    [SerializeField] Animator characterAnim;

    [Header("Movement-Jump And slide Effects")]
    [SerializeField] ParticleSystem JumpEffect;
    [SerializeField] ParticleSystem SlideEffect;
    [SerializeField] ParticleSystem HitEffect;
    [SerializeField] GameManager gameManager => GameManager.Instance;

    [Header("Security man")]
    [SerializeField] Animator SecurityAnim;
    [SerializeField] Transform SecurityTrans;
    [SerializeField] Transform S1;
    [SerializeField] Transform S2;
    [SerializeField] Transform S3;


    [Header("Touch Input")]

    private Vector2 startTouchPosition, endTouchPosition;
    private float swipeThreshold = 50f; // Adjust as needed

    void Update()
    {
        gameManager.uiManager.UpdateUI();
        if (gameManager.PlayerLives == 1)
        {
            SecurityTrans.position = Vector3.MoveTowards(SecurityTrans.position, S1.position, 0.1f);
            SecurityAnim.SetBool("Die", false);
        }
        else
        {
            if (gameManager.PlayerLives > 1)
            {
                SecurityTrans.position = Vector3.MoveTowards(SecurityTrans.position, S3.position, 0.1f);
                SecurityAnim.SetBool("Die", false);
            }
            if (gameManager.PlayerLives <= 0)
            {
                SecurityTrans.position = Vector3.MoveTowards(SecurityTrans.position, S2.position, 0.1f);
                SecurityAnim.SetBool("Die", true);
            }
        }


        if (gameManager.GameOver)
        {
            //Show ui
            return;
        }

        //  MoveHorizontally();
        HandleKeyboardInput();
        HandleTouchInput();
        PlayerMovement();
        MoveForward();
        playerAnim.speed = gameManager.WorldSpeedMultiplayer;
        characterAnim.speed = gameManager.WorldSpeedMultiplayer;
        SecurityAnim.speed = gameManager.WorldSpeedMultiplayer;

        if (Input.GetButtonDown("Jump") && isGrounded)
        {
            Jump();
        }


        if (!playerAnim.GetCurrentAnimatorStateInfo(0).IsName("Slide"))
        {

            if (Input.GetButtonDown("Slide"))
            {
                Slide();
            }
        }
    }

    void FixedUpdate()
    {
        isGrounded = Physics.Raycast(groundSensorTrans.position, Vector3.down, groundSensorDistance, Ground);
        Debug.DrawRay(groundSensorTrans.position, Vector3.down * groundSensorDistance, isGrounded ? Color.green : Color.red);
    }

    void Jump()
    {
        playerAnim.CrossFade("Jump", 0.1f, 0, 0f);
        characterAnim.CrossFade("Jump", 0.1f, 0, 0f);
        JumpEffect.Play();
        gameManager.CameraController.ShakeCamera(0.2f, 0.05f);
        gameManager.audioManager.PlaySoundEffectById("Jump");
    }

    void Slide()
    {
        playerAnim.CrossFade("Slide", 0.1f, 0, 0f);
        characterAnim.CrossFade("Slide", 0.1f, 0, 0f);
        //  gameManager.audioManager.PlaySoundEffectById("Slide");
        SlideEffect.Play();
    }
    public void MoveForward()
    {
        float distanceThisFrame = Vector3.forward.magnitude * RunSpeed * gameManager.WorldSpeedMultiplayer * Time.deltaTime;
        gameManager.totalDistance += distanceThisFrame;
        transform.Translate(Vector3.forward * RunSpeed * gameManager.WorldSpeedMultiplayer * Time.deltaTime);
    }
    void PlayerMovement()
    {
        Vector3 target = new Vector3(CurrPos.localPosition.x, PlayerPos.localPosition.y, PlayerPos.localPosition.z);
        PlayerPos.localPosition = Vector3.MoveTowards(PlayerPos.localPosition, target, horizontalSpeed * gameManager.WorldSpeedMultiplayer);

    }

    void MoveHorizontally()
    {

        if (CurrPos == MiddlePos)
        {
            if (Input.GetButtonDown("Right"))
            {
                CurrPos = RightPos;
                characterAnim.CrossFade("JumpRight", 0.01f);
                //    gameManager.audioManager.PlaySoundEffectById("MoveHorizontal");
            }
            if (Input.GetButtonDown("Left"))
            {
                CurrPos = LeftPos;
                characterAnim.CrossFade("JumpLeft", 0.01f);
                //  gameManager.audioManager.PlaySoundEffectById("MoveHorizontal");
            }
        }

        if (CurrPos == LeftPos)
        {
            if (Input.GetButtonDown("Right"))
            {
                CurrPos = MiddlePos;
                characterAnim.CrossFade("JumpRight", 0.01f);
                // gameManager.audioManager.PlaySoundEffectById("MoveHorizontal");
            }
        }

        if (CurrPos == RightPos)
        {
            if (Input.GetButtonDown("Left"))
            {
                CurrPos = MiddlePos;
                characterAnim.CrossFade("JumpLeft", 0.01f);
                // gameManager.audioManager.PlaySoundEffectById("MoveHorizontal");
            }
        }
    }
    void HandleTouchInput()
    {
        if (Input.touchCount > 0)
        {
            Touch touch = Input.GetTouch(0);

            switch (touch.phase)
            {
                case TouchPhase.Began:
                    startTouchPosition = touch.position;
                    break;

                case TouchPhase.Ended:
                    endTouchPosition = touch.position;
                    float horizontalSwipe = endTouchPosition.x - startTouchPosition.x;
                    float verticalSwipe = endTouchPosition.y - startTouchPosition.y;

                    // Determine if it was a horizontal or vertical swipe
                    if (Mathf.Abs(horizontalSwipe) > Mathf.Abs(verticalSwipe) && Mathf.Abs(horizontalSwipe) > swipeThreshold)
                    {
                        // Horizontal Swipe
                        if (horizontalSwipe > 0 && CurrPos != RightPos)
                        {
                            MoveRight();
                        }
                        else if (horizontalSwipe < 0 && CurrPos != LeftPos)
                        {
                            MoveLeft();
                        }
                    }
                    else if (Mathf.Abs(verticalSwipe) > swipeThreshold)
                    {
                        // Vertical Swipe
                        if (verticalSwipe > 0 && isGrounded) // Swipe Up for Jump
                        {
                            Jump();
                        }
                        else if (verticalSwipe < 0) // Swipe Down for Slide
                        {
                            if (!playerAnim.GetCurrentAnimatorStateInfo(0).IsName("Slide"))
                                Slide();
                        }
                    }
                    break;
            }
        }
    }

    void HandleKeyboardInput()
    {
        if (Input.GetButtonDown("Right"))
        {
            MoveRight();
        }

        if (Input.GetButtonDown("Left"))
        {
            MoveLeft();
        }
    }
    void MoveRight()
    {
        if (CurrPos == LeftPos)
        {
            CurrPos = MiddlePos;
        }
        else if (CurrPos == MiddlePos)
        {
            CurrPos = RightPos;
        }
        characterAnim.CrossFade("JumpRight", 0.01f);
    }

    void MoveLeft()
    {
        if (CurrPos == RightPos)
        {
            CurrPos = MiddlePos;
        }
        else if (CurrPos == MiddlePos)
        {
            CurrPos = LeftPos;
        }
        characterAnim.CrossFade("JumpLeft", 0.01f);
    }

    public void GitHit()
    {
        HitEffect.Play();
        characterAnim.CrossFade("Hit 1", 0.01f);
    }
    public void PlayerDie()
    {
        characterAnim.SetBool("Die", true);
        playerAnim.SetBool("Die", true);
    }
}
