# frozen_string_literal: true

# =============================================================================
# Fixtures - HTML samples of varying complexity for benchmarking
# =============================================================================
module Fixtures
  # ---------------------------------------------------------------------------
  # Helpers
  # ---------------------------------------------------------------------------
  def self.repeat(str, n)
    Array.new(n) { str }.join("\n")
  end

  # ---------------------------------------------------------------------------
  # SMALL — minimal newsletter-like email (~4 KB)
  # ---------------------------------------------------------------------------
  SMALL = <<~HTML
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="UTF-8">
      <style>
        body { margin: 0; padding: 0; font-family: Arial, sans-serif; background-color: #f5f5f5; }
        .container { max-width: 600px; margin: 0 auto; background-color: #ffffff; }
        .header { background-color: #2c3e50; padding: 20px; text-align: center; }
        .header h1 { color: #ffffff; font-size: 24px; margin: 0; }
        .content { padding: 30px; }
        .content p { color: #333333; font-size: 16px; line-height: 1.6; }
        .button { display: inline-block; background-color: #3498db; color: #ffffff;
                  padding: 12px 24px; text-decoration: none; border-radius: 4px; }
        .footer { background-color: #ecf0f1; padding: 20px; text-align: center; }
        .footer p { color: #7f8c8d; font-size: 12px; }
      </style>
    </head>
    <body>
      <div class="container">
        <div class="header"><h1>Monthly Newsletter</h1></div>
        <div class="content">
          <p>Hello,</p>
          <p>Welcome to our monthly newsletter. We have some exciting updates to share with you.</p>
          <p><a href="https://example.com/read-more" class="button">Read More</a></p>
        </div>
        <div class="footer"><p>Unsubscribe | Privacy Policy</p></div>
      </div>
    </body>
    </html>
  HTML

  # ---------------------------------------------------------------------------
  # MEDIUM — realistic transactional email with tables (~18 KB)
  # ---------------------------------------------------------------------------
  MEDIUM = begin
    rows = (1..20).map do |i|
      <<~ROW
        <tr>
          <td class="item-name">Product #{i} — Special Edition</td>
          <td class="item-qty">#{i}</td>
          <td class="item-price">${{ format('%.2f', 9.99 * i) }}</td>
          <td class="item-total">${{ format('%.2f', 9.99 * i * i) }}</td>
        </tr>
      ROW
    end.join

    <<~HTML
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="UTF-8">
        <style>
          body { margin: 0; padding: 0; font-family: 'Helvetica Neue', Arial, sans-serif;
                 background-color: #f4f4f4; color: #333333; }
          .wrapper { width: 100%; background-color: #f4f4f4; padding: 20px 0; }
          .container { max-width: 640px; margin: 0 auto; background-color: #ffffff;
                       border: 1px solid #dddddd; }
          .header { background-color: #1a1a2e; padding: 25px 30px; }
          .header h1 { color: #e94560; font-size: 28px; margin: 0; letter-spacing: -0.5px; }
          .header p { color: #a8a8b3; font-size: 14px; margin: 5px 0 0; }
          .order-meta { background-color: #f8f9fa; padding: 15px 30px;
                        border-bottom: 1px solid #eeeeee; }
          .order-meta table { width: 100%; border-collapse: collapse; }
          .order-meta td { font-size: 13px; color: #666666; padding: 4px 0; }
          .order-meta td:last-child { text-align: right; font-weight: bold; color: #333333; }
          .section { padding: 25px 30px; }
          .section h2 { font-size: 18px; color: #1a1a2e; margin: 0 0 15px;
                        padding-bottom: 8px; border-bottom: 2px solid #e94560; }
          .items-table { width: 100%; border-collapse: collapse; }
          .items-table th { background-color: #1a1a2e; color: #ffffff; font-size: 12px;
                            text-transform: uppercase; letter-spacing: 0.5px;
                            padding: 10px 12px; text-align: left; }
          .items-table td { padding: 12px; font-size: 14px; border-bottom: 1px solid #eeeeee; }
          .item-name { color: #333333; font-weight: 500; }
          .item-qty  { color: #666666; text-align: center; width: 60px; }
          .item-price { color: #666666; text-align: right; width: 80px; }
          .item-total { color: #333333; font-weight: bold; text-align: right; width: 90px; }
          .items-table tr:nth-child(even) td { background-color: #f8f9fa; }
          .totals { padding: 15px 30px; background-color: #f8f9fa;
                    border-top: 2px solid #eeeeee; }
          .totals table { width: 100%; border-collapse: collapse; max-width: 250px;
                          margin-left: auto; }
          .totals td { padding: 5px 0; font-size: 14px; }
          .totals td:last-child { text-align: right; }
          .totals .grand-total td { font-size: 18px; font-weight: bold;
                                    color: #e94560; padding-top: 10px; }
          .cta-section { padding: 25px 30px; text-align: center; }
          .btn-primary { display: inline-block; background-color: #e94560;
                         color: #ffffff; text-decoration: none;
                         padding: 14px 32px; font-size: 16px; font-weight: bold;
                         border-radius: 3px; }
          .btn-secondary { display: inline-block; background-color: transparent;
                           color: #e94560; text-decoration: none;
                           padding: 12px 28px; font-size: 14px; border: 2px solid #e94560;
                           border-radius: 3px; margin-left: 12px; }
          .footer { background-color: #1a1a2e; padding: 25px 30px; }
          .footer p { color: #a8a8b3; font-size: 12px; margin: 4px 0; line-height: 1.6; }
          .footer a { color: #e94560; text-decoration: none; }
          .social-links { margin: 15px 0; }
          .social-links a { color: #a8a8b3; text-decoration: none; margin: 0 8px;
                            font-size: 13px; }
          .divider { height: 1px; background-color: #2d2d44; margin: 15px 0; }
        </style>
      </head>
      <body>
        <div class="wrapper">
          <div class="container">
            <div class="header">
              <h1>Order Confirmed</h1>
              <p>Thank you for your purchase!</p>
            </div>
            <div class="order-meta">
              <table>
                <tr><td>Order Number</td><td>#ORD-2024-00123</td></tr>
                <tr><td>Order Date</td><td>January 15, 2024</td></tr>
                <tr><td>Payment Method</td><td>Visa •••• 4242</td></tr>
                <tr><td>Estimated Delivery</td><td>January 20–22, 2024</td></tr>
              </table>
            </div>
            <div class="section">
              <h2>Order Summary</h2>
              <table class="items-table">
                <thead>
                  <tr>
                    <th>Item</th>
                    <th>Qty</th>
                    <th>Price</th>
                    <th>Total</th>
                  </tr>
                </thead>
                <tbody>
                  #{rows}
                </tbody>
              </table>
            </div>
            <div class="totals">
              <table>
                <tr><td>Subtotal</td><td>$1,234.56</td></tr>
                <tr><td>Shipping</td><td>Free</td></tr>
                <tr><td>Tax (8%)</td><td>$98.76</td></tr>
                <tr class="grand-total"><td>Total</td><td>$1,333.32</td></tr>
              </table>
            </div>
            <div class="cta-section">
              <a href="https://example.com/orders/123" class="btn-primary">Track Your Order</a>
              <a href="https://example.com/support" class="btn-secondary">Need Help?</a>
            </div>
            <div class="footer">
              <div class="social-links">
                <a href="https://twitter.com/example">Twitter</a>
                <a href="https://facebook.com/example">Facebook</a>
                <a href="https://instagram.com/example">Instagram</a>
              </div>
              <div class="divider"></div>
              <p>© 2024 Example Corp. All rights reserved.</p>
              <p>123 Main Street, San Francisco, CA 94105</p>
              <p><a href="#">Unsubscribe</a> · <a href="#">Privacy Policy</a> · <a href="#">Terms</a></p>
            </div>
          </div>
        </div>
      </body>
      </html>
    HTML
  end

  # ---------------------------------------------------------------------------
  # LARGE — bulk promotional email (~60 KB, many elements)
  # ---------------------------------------------------------------------------
  LARGE = begin
    product_cards = (1..40).map do |i|
      hue = (i * 37) % 360
      <<~CARD
        <td class="product-card" style="width:175px">
          <div class="product-img" style="background-color:hsl(#{hue},60%,80%);
               height:120px; border-radius:4px; margin-bottom:8px;"></div>
          <p class="product-category">Category #{(i % 6) + 1}</p>
          <p class="product-name">Premium Product #{i}</p>
          <p class="product-desc">High quality item with excellent reviews and fast shipping.</p>
          <p class="product-rating">
            <span class="stars">★★★★#{i.even? ? '★' : '☆'}</span>
            <span class="review-count">(#{42 + (i * 7)} reviews)</span>
          </p>
          <p class="product-price">
            <span class="original-price">${{ format('%.2f', 49.99 + i * 10) }}</span>
            <span class="sale-price">${{ format('%.2f', 29.99 + i * 7) }}</span>
          </p>
          <a href="https://example.com/products/#{i}" class="add-to-cart">Add to Cart</a>
        </td>
      CARD
    end

    rows_of_4 = product_cards.each_slice(4).map do |group|
      "<tr>#{group.join}</tr>"
    end.join("\n")

    <<~HTML
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="UTF-8">
        <style>
          * { box-sizing: border-box; }
          body { margin:0; padding:0; font-family:'Helvetica Neue',Arial,sans-serif;
                 background-color:#f0f2f5; color:#1c1c1e; }
          .outer { background-color:#f0f2f5; padding:20px 0; }
          .container { max-width:800px; margin:0 auto; background:#fff; }

          /* Hero */
          .hero { background:linear-gradient(135deg,#667eea,#764ba2);
                  padding:50px 40px; text-align:center; }
          .hero h1 { color:#fff; font-size:36px; margin:0 0 10px; font-weight:800; }
          .hero p  { color:rgba(255,255,255,.85); font-size:18px; margin:0 0 24px; }
          .hero-badge { display:inline-block; background:rgba(255,255,255,.2);
                        color:#fff; padding:4px 14px; border-radius:100px;
                        font-size:13px; margin-bottom:16px; }
          .hero-cta { display:inline-block; background:#fff; color:#764ba2;
                      padding:14px 36px; font-size:18px; font-weight:700;
                      text-decoration:none; border-radius:50px; }
          .hero-subcta { display:block; color:rgba(255,255,255,.7);
                         font-size:13px; margin-top:12px; text-decoration:none; }

          /* Category bar */
          .category-bar { background:#2d3436; padding:0 30px; }
          .category-bar table { width:100%; border-collapse:collapse; }
          .category-bar td { padding:14px 10px; text-align:center; }
          .category-bar a { color:#dfe6e9; font-size:13px; text-decoration:none;
                            font-weight:500; letter-spacing:.3px; }
          .category-bar a:hover { color:#fff; }

          /* Flash sale banner */
          .flash-banner { background:#e17055; padding:12px 30px; text-align:center; }
          .flash-banner p { color:#fff; font-size:15px; margin:0; font-weight:600; }
          .flash-banner strong { font-size:18px; }

          /* Section headers */
          .section-header { padding:30px 30px 10px; }
          .section-header h2 { font-size:22px; color:#2d3436; margin:0 0 4px; font-weight:700; }
          .section-header p  { font-size:14px; color:#636e72; margin:0; }

          /* Products grid */
          .products-table { width:100%; border-collapse:collapse; padding:0 20px; }
          .product-card { padding:10px; vertical-align:top; }
          .product-category { font-size:11px; color:#b2bec3; text-transform:uppercase;
                              letter-spacing:.5px; margin:0 0 4px; }
          .product-name { font-size:14px; color:#2d3436; font-weight:600;
                          margin:0 0 4px; line-height:1.3; }
          .product-desc { font-size:12px; color:#636e72; margin:0 0 6px; line-height:1.4; }
          .product-rating { margin:0 0 6px; }
          .stars { color:#fdcb6e; font-size:12px; }
          .review-count { color:#b2bec3; font-size:11px; }
          .product-price { margin:0 0 8px; }
          .original-price { color:#b2bec3; text-decoration:line-through; font-size:12px;
                            margin-right:6px; }
          .sale-price { color:#e17055; font-size:16px; font-weight:700; }
          .add-to-cart { display:inline-block; background:#6c5ce7; color:#fff;
                         text-decoration:none; padding:7px 14px; font-size:12px;
                         font-weight:600; border-radius:4px; }

          /* Dividers */
          .section-divider { height:1px; background:#f0f2f5; margin:10px 30px; }

          /* Trust bar */
          .trust-bar { background:#f8f9fa; padding:20px 30px; }
          .trust-bar table { width:100%; border-collapse:collapse; }
          .trust-bar td { text-align:center; padding:10px; font-size:12px; color:#636e72; }
          .trust-icon { font-size:24px; display:block; margin-bottom:6px; }
          .trust-title { font-weight:700; color:#2d3436; font-size:13px; }

          /* Footer */
          .footer-top { background:#2d3436; padding:30px; }
          .footer-top table { width:100%; border-collapse:collapse; }
          .footer-top td { vertical-align:top; padding:0 15px 0 0; width:25%; }
          .footer-col-title { color:#dfe6e9; font-size:13px; font-weight:700;
                              text-transform:uppercase; letter-spacing:.5px;
                              margin:0 0 12px; }
          .footer-col-title p { color:#dfe6e9; font-size:13px; font-weight:700; margin:0 0 12px; }
          .footer-link { display:block; color:#b2bec3; font-size:12px;
                         text-decoration:none; margin-bottom:6px; line-height:1.5; }
          .footer-bottom { background:#1e272e; padding:15px 30px; text-align:center; }
          .footer-bottom p { color:#636e72; font-size:11px; margin:3px 0; }
          .footer-bottom a { color:#74b9ff; text-decoration:none; }
        </style>
      </head>
      <body>
        <div class="outer">
          <div class="container">
            <div class="hero">
              <span class="hero-badge">🔥 MEGA SALE — UP TO 60% OFF</span>
              <h1>Summer Clearance</h1>
              <p>Hundreds of products at unbeatable prices. Limited time only.</p>
              <a href="https://example.com/sale" class="hero-cta">Shop the Sale</a>
              <a href="https://example.com/sale" class="hero-subcta">View all deals →</a>
            </div>

            <div class="category-bar">
              <table><tr>
                <td><a href="#">Electronics</a></td>
                <td><a href="#">Fashion</a></td>
                <td><a href="#">Home & Garden</a></td>
                <td><a href="#">Sports</a></td>
                <td><a href="#">Beauty</a></td>
                <td><a href="#">Toys</a></td>
              </tr></table>
            </div>

            <div class="flash-banner">
              <p>⚡ Flash Deal ends in <strong>02:47:33</strong> — Extra 15% off with code FLASH15</p>
            </div>

            <div class="section-header">
              <h2>Featured Products</h2>
              <p>Handpicked deals just for you, updated daily.</p>
            </div>

            <table class="products-table">
              #{rows_of_4}
            </table>

            <div class="section-divider"></div>

            <div class="trust-bar">
              <table><tr>
                <td><span class="trust-icon">🚚</span><span class="trust-title">Free Shipping</span><br>On orders over $50</td>
                <td><span class="trust-icon">↩️</span><span class="trust-title">Easy Returns</span><br>30-day return policy</td>
                <td><span class="trust-icon">🔒</span><span class="trust-title">Secure Payment</span><br>SSL encrypted checkout</td>
                <td><span class="trust-icon">⭐</span><span class="trust-title">Top Rated</span><br>4.8/5 customer rating</td>
              </tr></table>
            </div>

            <div class="footer-top">
              <table><tr>
                <td>
                  <p class="footer-col-title">Company</p>
                  <a href="#" class="footer-link">About Us</a>
                  <a href="#" class="footer-link">Careers</a>
                  <a href="#" class="footer-link">Press</a>
                  <a href="#" class="footer-link">Blog</a>
                </td>
                <td>
                  <p class="footer-col-title">Support</p>
                  <a href="#" class="footer-link">Help Center</a>
                  <a href="#" class="footer-link">Contact Us</a>
                  <a href="#" class="footer-link">Order Status</a>
                  <a href="#" class="footer-link">Returns</a>
                </td>
                <td>
                  <p class="footer-col-title">Legal</p>
                  <a href="#" class="footer-link">Privacy Policy</a>
                  <a href="#" class="footer-link">Terms of Service</a>
                  <a href="#" class="footer-link">Cookie Policy</a>
                </td>
                <td>
                  <p class="footer-col-title">Follow Us</p>
                  <a href="#" class="footer-link">Twitter</a>
                  <a href="#" class="footer-link">Facebook</a>
                  <a href="#" class="footer-link">Instagram</a>
                  <a href="#" class="footer-link">YouTube</a>
                </td>
              </tr></table>
            </div>
            <div class="footer-bottom">
              <p>© 2024 Example Corp, Inc. All rights reserved.</p>
              <p><a href="#">Unsubscribe</a> · <a href="#">Manage Preferences</a> · <a href="#">Privacy</a></p>
            </div>
          </div>
        </div>
      </body>
      </html>
    HTML
  end

  # ---------------------------------------------------------------------------
  # COMPLEX_CSS — focuses on CSS parsing overhead: many selectors, pseudo-classes,
  # media queries, shorthand properties, specificity conflicts
  # ---------------------------------------------------------------------------
  COMPLEX_CSS = begin
    # Generate a large CSS block with many rules
    selectors_css = (1..80).map do |i|
      ".element-#{i} { " \
        "color: rgb(#{i * 3 % 255}, #{i * 7 % 255}, #{i * 13 % 255}); " \
        "font-size: #{10 + (i % 14)}px; " \
        "margin: #{i % 20}px #{i % 15}px #{i % 10}px #{i % 8}px; " \
        "padding: #{i % 12}px #{i % 18}px; " \
        "background-color: ##{format('%06x', (i * 123_456) % 0xFFFFFF)}; " \
        "border: #{i % 4}px solid ##{format('%06x', (i * 654_321) % 0xFFFFFF)}; " \
        "line-height: #{1.0 + ((i % 10) * 0.1)}; " \
        "letter-spacing: #{i % 3}px; " \
        "text-transform: #{['none', 'uppercase', 'lowercase', 'capitalize'][i % 4]}; " \
        "}"
    end.join("\n")

    # Unmergeable rules (hover/media) to test that pathway
    unmergeable_css = (1..20).map do |i|
      ".element-#{i}:hover { background-color: ##{format('%06x', i * 111_111 % 0xFFFFFF)}; color: white; }"
    end.join("\n")

    media_css = "@media screen and (max-width: 600px) {\n" +
      (1..10).map { |i| "  .element-#{i} { display: block; width: 100%; }" }.join("\n") +
      "\n}"

    # Specificity conflicts: td styles overridden by class styles
    specificity_css = <<~CSS
      td { color: #333333; font-size: 14px; padding: 8px; }
      td.highlight { color: #e74c3c; font-weight: bold; }
      table td.highlight { color: #c0392b; font-weight: 800; font-size: 16px; }
      .container table td.highlight { color: #a93226; }
    CSS

    # Shorthand expansion stress
    shorthand_css = (1..30).map do |i|
      ".shorthand-#{i} { " \
        "font: italic bold #{10 + i}px/#{1.2 + (i * 0.05)} 'Helvetica Neue', Arial, sans-serif; " \
        "border: #{(i % 5) + 1}px #{['solid', 'dashed', 'dotted'][i % 3]} ##{format('%06x', i * 77_777 % 0xFFFFFF)}; " \
        "padding: #{i}px #{i * 2}px; " \
        "margin: #{i}px auto; " \
        "}"
    end.join("\n")

    elements = (1..80).map do |i|
      "<div class=\"element-#{i}\">
        <p class=\"shorthand-#{(i % 30) + 1}\">Paragraph #{i} with complex styling applied.</p>
        <a href=\"https://example.com/link-#{i}\">Link #{i}</a>
      </div>"
    end.join("\n")

    table_rows = (1..15).map do |i|
      "<tr><td#{i % 3 == 0 ? ' class="highlight"' : ''}>Row #{i}, Col 1</td>" \
        "<td#{i % 5 == 0 ? ' class="highlight"' : ''}>Row #{i}, Col 2</td>" \
        "<td>Row #{i}, Col 3</td></tr>"
    end.join("\n")

    <<~HTML
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="UTF-8">
        <style>
          body { font-family: Arial, sans-serif; margin: 0; padding: 20px; background: #f5f5f5; }
          .container { max-width: 700px; margin: 0 auto; background: white; padding: 20px; }
          #{selectors_css}
          #{unmergeable_css}
          #{media_css}
          #{specificity_css}
          #{shorthand_css}
        </style>
      </head>
      <body>
        <div class="container">
          <h1>CSS Complexity Benchmark</h1>
          #{elements}
          <table>
            <thead><tr><th>Col 1</th><th>Col 2</th><th>Col 3</th></tr></thead>
            <tbody>#{table_rows}</tbody>
          </table>
        </div>
      </body>
      </html>
    HTML
  end

  # ---------------------------------------------------------------------------
  # MANY_LINKS — stress-tests `convert_inline_links` and `append_query_string`
  # ---------------------------------------------------------------------------
  MANY_LINKS = begin
    link_rows = (1..100).map do |i|
      domain = ['example.com', 'shop.example.com', 'blog.example.com', 'cdn.example.com'][i % 4]
      <<~ROW
        <tr>
          <td><a href="https://#{domain}/product/#{i}">Product #{i}</a></td>
          <td><a href="https://#{domain}/category/#{i % 10}">Category #{i % 10}</a></td>
          <td><img src="https://cdn.example.com/images/product-#{i}.jpg" width="50" height="50" alt="Product #{i}"></td>
          <td><a href="https://#{domain}/review/#{i}" rel="nofollow">Review</a></td>
        </tr>
      ROW
    end.join

    <<~HTML
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="UTF-8">
        <style>
          body { font-family: Arial, sans-serif; margin: 0; background: #f5f5f5; }
          .container { max-width: 700px; margin: 0 auto; background: white; }
          table { width: 100%; border-collapse: collapse; }
          th { background-color: #2c3e50; color: white; padding: 10px; text-align: left; }
          td { padding: 8px 10px; border-bottom: 1px solid #eeeeee; font-size: 14px; }
          a { color: #3498db; text-decoration: none; }
          img { border: 1px solid #dddddd; border-radius: 3px; }
          tr:nth-child(even) td { background-color: #f8f9fa; }
          .header { background: #2c3e50; padding: 20px 30px; }
          .header h1 { color: white; margin: 0; }
          .footer { padding: 20px 30px; text-align: center; font-size: 12px; color: #666; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header"><h1>Product Catalog (100 items)</h1></div>
          <table>
            <thead><tr><th>Name</th><th>Category</th><th>Image</th><th>Actions</th></tr></thead>
            <tbody>#{link_rows}</tbody>
          </table>
          <div class="footer">
            <p>
              <a href="https://example.com">Home</a> ·
              <a href="https://example.com/about">About</a> ·
              <a href="https://example.com/unsubscribe">Unsubscribe</a>
            </p>
          </div>
        </div>
      </body>
      </html>
    HTML
  end

  ALL = {
    small: SMALL,
    medium: MEDIUM,
    large: LARGE,
    complex_css: COMPLEX_CSS,
    many_links: MANY_LINKS
  }.freeze
end
