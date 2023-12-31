/**
 * Service class for operations on posts and related comments.
 */
global with sharing class NewsAnnouncementsService {

	/**
	 * Method to fetch recent posts, newest first limited by limitSize
	 */
	global static List<Post__c> fetchRecentPosts(Integer limitSize) {
		return [SELECT Id, Name, Content__c, (SELECT Id, Name, Content__c FROM Comments__r) 
				FROM Post__c 
				ORDER BY CreatedDate DESC 
				LIMIT :limitSize];
	}

	/**
	 * Fetch comments by parent post Id, oldest first
	 */
	global static List<Comment__c> fetchComments(Id postId) {
		return [SELECT Id, Name, Content__c, Post__c, CreatedBy.Name
				FROM Comment__c
				WHERE Post__c = :postId
				ORDER BY CreatedDate];
	}

	/**
	 * Add comment to a post
	 */
	global static void addComment(Id postId, String content) {
		insert new Comment__c(
			Post__c = postId,
			Content__c = content
		);
	}

	/**
	 * Update comment on a post
	 */
	global static void updateComment(Id commentId, String content) {
		update new Comment__c(
			Id = commentId,
			Content__c = content
		);
	}

	/**
	 * Delete a comment
	 */
	global static void deleteComment(Id commentId) {
		delete [SELECT Id From Comment__c WHERE Id = :commentId ];
	}
}
