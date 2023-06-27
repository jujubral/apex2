/**
 * Controller class for PostDetails page
 */
public with sharing class PostDetailsController {

	private Id postId;
	private Post__c post;
	private Map<String, CommentDetail> commentMap;
	private String newRecordIdentifier = 'new record';
	public Id commentToEditOrDelete { get; set; }

	public PostDetailsController(ApexPages.StandardController controller) {
		post = (Post__c)controller.getRecord();
		postId = post.Id;

		fetchCommentDetails();
	}

	public List<CommentDetail> getCommentDetails() {
		return commentMap.values();
	}

	public void handleAddCommentClick() {
		CommentDetail detail = new CommentDetail();
		detail.EditMode = true;
		commentMap.put(newRecordIdentifier, detail);
	}

	public void handleEditClick() {
		commentMap.get(commentToEditOrDelete).EditMode = true;
	}

	public PageReference handleSaveClick() {
		CommentDetail detail;
		Comment__c comment = new Comment__c();

		if(String.isBlank(commentToEditOrDelete)) {
			detail = commentMap.get(newRecordIdentifier);
			NewsAnnouncementsService.addComment(postId, detail.content);
		} else {
			detail = commentMap.get(commentToEditOrDelete);
			NewsAnnouncementsService.updateComment(commentToEditOrDelete, detail.content); 
		}

		fetchCommentDetails();

		return null;
	}

	public void handleDeleteClick() {
		NewsAnnouncementsService.deleteComment(commentToEditOrDelete);

		fetchCommentdetails();
	}

	public void handleCancelClick() {
		fetchCommentDetails();
	}

	private void fetchCommentDetails() {
		// Security check for read access
		PermissionChecker.checkPermissionAndThrowException(Comment__c.SObjectType, PermissionChecker.Intent.READ);
		PermissionChecker.checkPermissionAndThrowException(Comment__c.SObjectType, Comment__c.Content__c, PermissionChecker.Intent.READ);
		
		commentMap = new Map<String, CommentDetail>();
		List<Comment__c> comments = NewsAnnouncementsService.fetchComments(postId);

		for(Comment__c comment: comments) {
			CommentDetail detail = new CommentDetail();

			detail.RecordId = comment.Id;
			detail.Content = comment.Content__c;
			detail.CommentedBy = comment.CreatedBy.Name;

			commentMap.put(detail.RecordId, detail);
		}
	}

	/**
	 * Wrapper class for wrapping Comment details
	 */
	public class CommentDetail {
		public Id RecordId { get; set; }
		public String Content { get; set; }
		public String CommentedBy { get; set; }
		public Boolean EditMode { get; set; }
	}

}
