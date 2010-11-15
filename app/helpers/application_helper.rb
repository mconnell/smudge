module ApplicationHelper

  def like_buttons
    raw <<-HTML
      <div style="float:right; padding-top: 4px">
        #{facebook_like_button}
        #{twitter_like_button}
      </div>
    HTML
  end

  def facebook_like_button
    raw <<-HTML
      <iframe src="http://www.facebook.com/plugins/like.php?href=http%3A%2F%2Fsmudge.it#{request.request_uri.gsub('/', '%2F')}&amp;layout=button_count&amp;width=50&amp;action=like&amp;colorscheme=light&amp;height=21"
      scrolling="no"
      frameborder="0"
      style="margin-left: 1em; float:right; border:none; overflow:hidden; width:49px; height:21px;"
      allowTransparency="true">
      </iframe>
    HTML
  end

  def twitter_like_button
    raw <<-HTML
      <a href="http://twitter.com/share"
         class="twitter-share-button"
         data-count="none">Tweet</a>
      <script type="text/javascript" src="http://platform.twitter.com/widgets.js"></script>
    HTML
  end

end
