# Secret Messenger Mobile Application

Here is **messenger app**, which is made using 

**Flutter framework** and **Firebase Realtime Database + Firebase Cloud Storage**. 

I use **Google Sign In**  functionality for logging in and authorizing. 

Messages are encrypted with end-to-end encryption, so **even server didnt know what messages really contains.**

Also i made **biometric authentication** for add layer of sequrity. 
I tested it on phone, which support it and it **works**. But if your phone didnt support it, you can skip it. 

On this app you can send text, video and picture messages. 

Please use smallweighted mediafiles, since i use free google storage which accepts only 1gb bandwich on day. I host smallweight video and picture for testing [here](https://drive.google.com/drive/folders/1pHrxOC2alSrsKRbPrucMeXBWz8GbRWpB?usp=sharing). You can use them or own files.

Oh, and here i recorded small videos for showing app functionality:
- [Image & video sending](https://drive.google.com/file/d/1LOyAPh3Mf_pGkWHrMaFu31-KJ2fLtEbj/view?usp=sharing)
- [Deleting messages](https://drive.google.com/file/d/1TN3Au8TMrJfr4R8qWzp0fZVNMDzRUJLJ/view?usp=sharing)
- [Edit messages](https://drive.google.com/file/d/1JgQSPsttEKAqP_Ltd_nihv_iOCZOWMEN/view?usp=sharing)

- [Here](https://drive.google.com/file/d/1nx_pfsDQ1MhmO2d5f90LaGXudfY7lz0h/view?usp=sharing) is proof that Database saves messages in encoded way.

Little bit explanation: Message is encoded with sender secret key and receiver public key. This pattern is named **end-to-end encryption**.  So only sender and receiver can really decode a message. I encode plain text on client and save it on encoded way in database. Then message receiver decode this encoded data with sender public key and receiver secret key, which is stored on receiver device local storage.

Thats it!


Thank you very much for your time, good luck!

[Apk](https://drive.google.com/file/d/1vlCG6cVfQTHUYHWcxxc_0ei5_rc3sbkF/view?usp=sharing)

