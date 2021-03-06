use quickiePostsDB;

-- get comments I can see only
select postID, count(*) as tComments 
from comments LEFT JOIN users on users.userID = comments.userID
LEFT JOIN (select * from viewers WHERE viewers.viewerID = 3) viewers on viewers.posterID = comments.userID
LEFT JOIN (select * from blocked WHERE blockedID = 3) isBlockingMe on isBlockingMe.blockerID = comments.userID
LEFT JOIN (select * from blocked WHERE blockerID = 3) amBlockingThem on amBlockingThem.blockedID = comments.userID,
(select userID,classification from users WHERE userID = 3) classification
WHERE (classification.classification = "admin")
OR ((comments.visibility != "hidden" and  users.visibility != "hidden")
AND (isBlockingMe.blockedID is null AND amBlockingThem.blockerID is null)
AND ((comments.visibility != 'private' AND users.visibility != 'private')
OR viewers.viewerID is not null)) GROUP BY postID
;
-- get comments anyone can see
select postID, count(*) as tComments from comments 
LEFT JOIN users on users.userID = comments.userID
WHERE users.visiblity = "public"
AND comments.visibility = "public" GROUP BY postID
;

      SELECT * FROM (
      SELECT posts.postID as postID, posts.userID as userID, posts.title as title, posts.content as content, posts.visibility as postVisibility, posts.subDate as postDate,
      users.userName as username, users.email as email, users.visibility as userVisibility, ifnull(tLikes,0) as totalLikes, if(isLiked.postID is null,"false","true") as Liked,
      ifnull(tComments,0) as totalComments, if(blockingThem.blockerID is null, "false","true") as amBlockingThem, if(blockingMe.blockedID is null,"false","true") as isBlockingMe,
      if(viewers.viewerID is null, "false","true") as isViewer, checkAdmin.classification as viewerClassification
      FROM posts LEFT JOIN users ON posts.userID = users.userID
      LEFT JOIN (select postID,count(*) as tLikes from likes GROUP BY postID) totalLikes ON totalLikes.postID = posts.postID -- totalLikes
      LEFT JOIN (select * FROM likes as Liked WHERE userID = 3) isLiked ON isLiked.postID = posts.postID -- isLiked
      LEFT JOIN (
        select postID, count(*) as tComments
        from comments LEFT JOIN users on users.userID = comments.userID
        LEFT JOIN (select * from viewers WHERE viewers.viewerID = 3) viewers on viewers.posterID = comments.userID
        LEFT JOIN (select * from blocked WHERE blockedID = 3) isBlockingMe on isBlockingMe.blockerID = comments.userID
        LEFT JOIN (select * from blocked WHERE blockerID = 3) amBlockingThem on amBlockingThem.blockedID = comments.userID,
        (select userID,classification from users WHERE userID = 3) classification
        WHERE (classification.classification = "admin")
        OR ((comments.visibility != "hidden" and  users.visibility != "hidden")
        AND (isBlockingMe.blockedID is null AND amBlockingThem.blockerID is null)
        AND ((comments.visibility != 'private' AND users.visibility != 'private')
        OR viewers.viewerID is not null)) GROUP BY postID
      ) comments ON comments.postID = posts.postID -- totalComments
      LEFT JOIN (select * from blocked WHERE blockerID = 3) blockingThem ON blockingThem.blockedID = posts.userID --  meblockingthem
      LEFT JOIN (select * from blocked where blockedID = 3) blockingMe on blockingMe.blockerID = posts.userID  -- themblockingme
      LEFT JOIN (select * from viewers WHERE viewerID = 3) viewers on viewers.posterID = posts.userID -- viewingThem
      , (select * from users WHERE userID = 3) checkAdmin
      ) posts LEFT JOIN (SELECT * FROM
      (SELECT comments.commentID as commentID, postID as pyostID, comments.userID as commenterID, comments, comments.visibility as commentVisibility, submissionDate as commentDate,
      users.userName as commentername, users.visibility as commenterVisibility, ifnull(totalCommentLikes,0) as totalCommentLikes, if(commentLiked.commentID is null,"false","true") as commentLiked,
      if(meBlockingThem.blockerID is null,"false","true") as amBlockingCommenter, if(themBlockingMe.blockerID is null,"false","true") as CommenterBlockingMe,
      if(viewers.viewerID is null, "false","true") as isViewerCommenter, checkAdmin.classification as userClassification
      FROM comments LEFT JOIN users on comments.userID = users.userID
      LEFT JOIN (select commentID, count(*) as totalCommentLikes from commentLikes GROUP BY commentID) commentLikes on commentLikes.commentID = comments.commentID
      LEFT JOIN (select * from commentLikes WHERE userID = 3) commentLiked on commentLiked.commentID = comments.commentID
      LEFT JOIN (select * from blocked WHERE blockerID = 3) meBlockingThem on meBlockingThem.blockedID = comments.userID
      LEFT JOIN (select * from blocked WHERE blockedID = 3) themBlockingMe on themBlockingMe.blockerID = comments.userID
      LEFT JOIN (select * from viewers WHERE viewerID = 3) viewers on viewers.posterID = comments.userID -- viewingThem
      ,(select * from users WHERE userID = 3) checkAdmin
      ) comments WHERE userClassification = "admin"
      OR ((amBlockingCommenter = "false" AND commenterBlockingMe = "false")
      AND commenterVisibility != "hidden" AND commentVisibility != "hidden"
      AND ((isViewerCommenter = "true") OR (commenterVisibility != "private" OR commentVisibility != "private" OR commenterID = 3))
      )) comments on posts.postID = comments.pyostID
      WHERE postID = 20 AND  (viewerClassification = "admin"
      OR ((amBlockingThem = "false" AND isBlockingMe = "false")
      AND userVisibility != "hidden" AND postVisibility != "hidden"
      AND ((isViewer = "true") OR (userVisibility != "private" OR postVisibility != "private" or userID = 3))
      )) ORDER BY commentDate DESC;
-- 	select * from bans;
-- 	DELETE FROM bans WHERE bannedID = 15;
-- 	INSERT INTO bans
-- 	SELECT userID FROM users
-- 	WHERE userID = 15 AND classification != "admin";