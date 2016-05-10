# Forums

Your project is to build a small forum application for Rails. You should be able to do the following things in it:

* Create a Forum with a Title + Description.
* Add a topic to that forum by way of a "New Topic" button on the forums#show page (just a form with a "Subject" field will do)
* View a forum's topics
* Add a post to the topic (just a form with a "Text" field)
* View a topic's posts

You'll end up with a Forum having many topics, and topics having many posts.

You should write tests for each of these features before you develop them.

## "Bonus Credit"

1. **Process the post's content using the `redcarpet` gem**. This will allow users to write posts in Markdown and have them displayed as HTML. There's no need to write tests for this.
2. **Create the first post and topic together**. The keywords you're looking for are "Rails nested attributes" and "fields_for". The form for creating a topic should also have the post's text field on it as well. Once the form has been submitted, a new topic and post should be created.
3. **Associate posts to authors**. Add Devise to the application and allow users to sign in. If they're signed in, then the post should display who authored it. If they aren't, then just show "Anonymous"

## Evalulation

This application will be evaluated based on the following metrics:

1. Compliance with Ruby syntax rules.
2. Demonstrated understanding of Rails best practices
3. BDD/TDD tests written in either RSpec or Minitest.
