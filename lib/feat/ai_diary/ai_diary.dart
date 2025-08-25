import 'package:flutter/material.dart';

class AiDiary extends StatelessWidget {
  const AiDiary({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('AI絵日記'),
      content: SizedBox(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            // タブ部分
            SizedBox(
              width: double.infinity,
              height: 44,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: ShapeDecoration(
                        color: const Color(0xFFE8DEF8),
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            width: 1,
                            color: const Color(0xFF79747E),
                          ),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(100),
                            bottomLeft: Radius.circular(100),
                          ),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'タスクをしないと？',
                          style: TextStyle(
                            color: const Color(0xFF4A4459),
                            fontSize: 12,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            width: 1,
                            color: const Color(0xFF79747E),
                          ),
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(100),
                            bottomRight: Radius.circular(100),
                          ),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'タスクをすると？',
                          style: TextStyle(
                            color: const Color(0xFF1D1B20),
                            fontSize: 12,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 画像部分
            SizedBox(
              width: double.infinity,
              height: 220,
              child: Container(
                decoration: BoxDecoration(
                  image: const DecorationImage(
                    image: AssetImage("assets/images/sacabambaspis.png"),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // テキスト部分
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF9F9F9), // 薄いグレー背景
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(16), // padding を設ける
                child: SingleChildScrollView(
                  child: Text(
                    'くぅ～疲れましたw これにて完結です！\n実は、ネタレスしたら代行の話を持ちかけられたのが始まりでした\n本当は話のネタなかったのですが←\nご厚意を無駄にするわけには行かないので流行りのネタで挑んでみた所存ですw\n以下、まどか達のみんなへのメッセジをどぞ\nまどか「みんな、見てくれてありがとう\nちょっと腹黒なところも見えちゃったけど・・・気にしないでね！」\nさやか「いやーありがと！\n私のかわいさは二十分に伝わったかな？」\nマミ「見てくれたのは嬉しいけどちょっと恥ずかしいわね・・・」\n京子「見てくれありがとな！\n正直、作中で言った私の気持ちは本当だよ！」\nほむら「・・・ありがと」ﾌｧｻ\nでは、\nまどか、さやか、マミ、京子、ほむら、俺「皆さんありがとうございました！」\n終\nまどか、さやか、マミ、京子、ほむら「って、なんで俺くんが！？\n改めまして、ありがとうございました！」\n本当の本当に終わり',
                    style: TextStyle(
                      color: const Color(0xFF1D1B20),
                      fontSize: 14,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w400,
                      height: 1.57,
                      letterSpacing: 0.56,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('閉じる'),
        ),
      ],
    );
  }
}
