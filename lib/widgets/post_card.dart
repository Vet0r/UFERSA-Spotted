import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:spotted_ufersa/models/user.dart' as model;
import 'package:spotted_ufersa/providers/user_provider.dart';
import 'package:spotted_ufersa/resources/firestore_methods.dart';
import 'package:spotted_ufersa/screens/comments_screen.dart';
import 'package:spotted_ufersa/screens/full_image.dart';
import 'package:spotted_ufersa/utils/colors.dart';
import 'package:spotted_ufersa/utils/global_variable.dart';
import 'package:spotted_ufersa/utils/utils.dart';
import 'package:spotted_ufersa/widgets/like_animation.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PostCard extends StatefulWidget {
  final snap;
  const PostCard({
    Key? key,
    required this.snap,
  }) : super(key: key);

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  int commentLen = 0;
  bool isLikeAnimating = false;

  @override
  void initState() {
    super.initState();
    fetchCommentLen();
  }

  fetchCommentLen() async {
    try {
      QuerySnapshot snap = await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.snap['postId'])
          .collection('comments')
          .get();
      commentLen = snap.docs.length;
    } catch (err) {
      showSnackBar(
        context,
        err.toString(),
      );
    }
    setState(() {});
  }

  deletePost(String postId) async {
    try {
      await FireStoreMethods().deletePost(postId);
    } catch (err) {
      showSnackBar(
        context,
        err.toString(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final model.User user = Provider.of<UserProvider>(context).getUser;

    return Padding(
      padding: const EdgeInsets.only(top: 15.0),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: internalPostColor,
            ),
            width: MediaQuery.of(context).size.width * .90,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(right: 8.0),
                              child: Icon(Icons.pin_drop, size: 15),
                            ),
                            Text(
                              widget.snap['campus'].toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      widget.snap['uid'].toString() == user.uid
                          ? buttonDelete(
                              context,
                              deletePost,
                              widget.snap['postId'].toString(),
                            )
                          : Container(),
                    ],
                  ),
                  GestureDetector(
                    onDoubleTap: () {
                      FireStoreMethods().likePost(
                        widget.snap['postId'].toString(),
                        user.uid,
                        widget.snap['likes'],
                      );
                      setState(() {
                        isLikeAnimating = true;
                      });
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.35,
                          width: double.infinity,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20.0),
                            child: Image.network(
                              widget.snap['postUrl'].toString(),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: isLikeAnimating ? 1 : 0,
                          child: LikeAnimation(
                            isAnimating: isLikeAnimating,
                            duration: const Duration(
                              milliseconds: 400,
                            ),
                            onEnd: () {
                              setState(() {
                                isLikeAnimating = false;
                              });
                            },
                            child: const Icon(
                              Icons.favorite,
                              color: Colors.white,
                              size: 100,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  //DESCRIPTION AND NUMBER OF COMMENTS
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: 10,
                      ),
                      widget.snap['description'] != ""
                          ? Container(
                              decoration: BoxDecoration(
                                color: internalPostColor,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              height: MediaQuery.of(context).size.height * 0.05,
                              width: double.infinity,
                              padding: const EdgeInsets.only(
                                top: 8,
                              ),
                              child: Center(
                                child: RichText(
                                  text: TextSpan(
                                    style: const TextStyle(color: primaryColor),
                                    children: [
                                      TextSpan(
                                        text: ' ${widget.snap['description']}',
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          : Container(),
                      InkWell(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            '$commentLen ${commentLen == 1 ? "comentário" : "comentários"}',
                            style: const TextStyle(
                              fontSize: 16,
                              color: secondaryColor,
                            ),
                          ),
                        ),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => CommentsScreen(
                              postId: widget.snap['postId'].toString(),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          DateFormat.yMMMd('pt_BR')
                              .format(widget.snap['datePublished'].toDate()),
                          style: const TextStyle(
                            color: secondaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // LIKE, COMMENT SECTION OF THE POST
                  Row(
                    children: <Widget>[
                      Text(
                        '${widget.snap['likes'].length}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      LikeAnimation(
                        isAnimating: widget.snap['likes'].contains(user.uid),
                        smallLike: true,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: widget.snap['likes'].contains(user.uid)
                              ? const Icon(
                                  Icons.favorite,
                                  color: Colors.red,
                                )
                              : const Icon(
                                  Icons.favorite_border,
                                ),
                          onPressed: () => FireStoreMethods().likePost(
                            widget.snap['postId'].toString(),
                            user.uid,
                            widget.snap['likes'],
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.comment_outlined,
                        ),
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => CommentsScreen(
                              postId: widget.snap['postId'].toString(),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                          icon: const Icon(
                            Icons.send,
                          ),
                          onPressed: () {}),
                      widget.snap['likes'].contains(user.uid)
                          ? Expanded(
                              child: Align(
                                alignment: Alignment.bottomRight,
                                child: IconButton(
                                  icon: const Icon(Icons.fullscreen),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            FullScreenImage(
                                          imageUrl:
                                              widget.snap['postUrl'].toString(),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            )
                          : Container(),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

buttonDelete(BuildContext context, Function deletePost, String postId) {
  return IconButton(
    onPressed: () {
      showDialog(
        useRootNavigator: false,
        context: context,
        builder: (context) {
          return Dialog(
            child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shrinkWrap: true,
                children: [
                  'Deletar Post',
                ]
                    .map(
                      (e) => InkWell(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 16),
                            child: Text(e),
                          ),
                          onTap: () {
                            deletePost(postId);
                            // remove the dialog box
                            Navigator.of(context).pop();
                          }),
                    )
                    .toList()),
          );
        },
      );
    },
    icon: const Icon(Icons.more_vert),
  );
}
