import json
import os
import logging
import boto3
from botocore.exceptions import ClientError

logger = logging.getLogger()
logger.setLevel(logging.INFO)

_ses_region = os.environ.get('AWS_SES_REGION', 'ap-northeast-3')
ses_client = boto3.client(
  'ses',
  region_name=_ses_region,
  endpoint_url=f"https://email.{_ses_region}.amazonaws.com"
)

SENDER_EMAIL = os.environ.get('SES_SENDER_EMAIL', '')


def lambda_handler(event, context):
    logger.info('Email Lambda triggered')
    logger.info(f'Records received: {len(event.get("Records", []))}')

    failed_records = []

    for i, record in enumerate(event.get('Records', [])):
        try:
            process_record(record)
        except Exception as e:
            logger.error(f'Failed to process record {i}: {str(e)}')
            failed_records.append({'record_index': i, 'error': str(e)})

    if failed_records:
        raise Exception(f'Failed to process {len(failed_records)} record(s): {failed_records}')

    logger.info('All records processed successfully')
    return {'statusCode': 200}


def process_record(record):
    body = json.loads(record['body'])

    booking_ref = body.get('booking_ref', 'UNKNOWN')
    logger.info(f'Processing booking: {booking_ref}')

    recipient_email = (
        body.get('guest_email')
        or body.get('traveler', {}).get('email')
    )

    if not recipient_email:
        raise ValueError('No recipient email found in message body')

    logger.info(f'Sending confirmation email to: {recipient_email}')

    subject = f"Booking Confirmed — {booking_ref} | {body.get('room', {}).get('title', 'Your Room')}"
    html_body = build_html_email(body)
    text_body = build_text_email(body)

    send_email(
        recipient=recipient_email,
        subject=subject,
        html_body=html_body,
        text_body=text_body,
    )

    logger.info(f'Email sent successfully to {recipient_email} for booking {booking_ref}')


def send_email(recipient, subject, html_body, text_body):
    if not SENDER_EMAIL:
        raise ValueError('SES_SENDER_EMAIL environment variable is not set')

    try:
        response = ses_client.send_email(
            Source=SENDER_EMAIL,
            Destination={
                'ToAddresses': [recipient],
            },
            Message={
                'Subject': {
                    'Data': subject,
                    'Charset': 'UTF-8',
                },
                'Body': {
                    'Html': {
                        'Data': html_body,
                        'Charset': 'UTF-8',
                    },
                    'Text': {
                        'Data': text_body,
                        'Charset': 'UTF-8',
                    },
                },
            },
        )
        logger.info(f'SES MessageId: {response["MessageId"]}')
        return response
    except ClientError as e:
        error_code = e.response['Error']['Code']
        error_message = e.response['Error']['Message']
        logger.error(f'SES ClientError [{error_code}]: {error_message}')
        raise


def build_html_email(booking):
    pricing = booking.get('pricing', {})
    stay = booking.get('stay', {})
    room = booking.get('room', {})
    traveler = booking.get('traveler', {})
    currency = pricing.get('currency', '')
    property_name = booking.get('property_name', 'Internet Booking Engine')
    booking_ref = booking.get('booking_ref', 'N/A')
    unique_url = booking.get('unique_booking_url', '#')
    guests = booking.get('guests', {})
    guest_summary = guests.get('summary', '')

    return f"""
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <style>
    body {{
      font-family: Arial, sans-serif;
      color: #333333;
      margin: 0;
      padding: 0;
      background-color: #f5f5f5;
    }}
    .wrapper {{
      background-color: #f5f5f5;
      padding: 24px 0;
    }}
    .container {{
      max-width: 600px;
      margin: 0 auto;
      background: #ffffff;
      border-radius: 6px;
      overflow: hidden;
      box-shadow: 0 2px 8px rgba(0,0,0,0.08);
    }}
    .header {{
      background-color: #1a237e;
      color: #ffffff;
      padding: 24px 28px;
    }}
    .header h1 {{
      margin: 0 0 4px 0;
      font-size: 20px;
      font-weight: 700;
    }}
    .header p {{
      margin: 0;
      font-size: 13px;
      opacity: 0.80;
    }}
    .body {{
      padding: 28px 28px 20px 28px;
    }}
    .booking-ref {{
      font-size: 24px;
      font-weight: 700;
      color: #1a237e;
      margin: 0 0 8px 0;
    }}
    .confirmed-msg {{
      font-size: 14px;
      color: #555555;
      line-height: 1.6;
      margin: 0 0 24px 0;
    }}
    .section {{
      margin-bottom: 20px;
      padding-bottom: 20px;
      border-bottom: 1px solid #eeeeee;
    }}
    .section:last-child {{
      border-bottom: none;
      margin-bottom: 0;
      padding-bottom: 0;
    }}
    .section-title {{
      font-size: 13px;
      font-weight: 700;
      color: #1a1a2e;
      margin: 0 0 12px 0;
      text-transform: uppercase;
      letter-spacing: 0.5px;
    }}
    .dates-row {{
      display: flex;
    }}
    .date-box {{
      border: 1px solid #dddddd;
      border-radius: 4px;
      padding: 10px 20px;
      text-align: center;
      margin-right: 12px;
      min-width: 90px;
    }}
    .date-label {{
      font-size: 10px;
      color: #999999;
      text-transform: uppercase;
      margin: 0 0 4px 0;
    }}
    .date-value {{
      font-size: 22px;
      font-weight: 700;
      color: #1a1a2e;
      line-height: 1;
      margin: 0 0 2px 0;
    }}
    .date-month {{
      font-size: 12px;
      color: #666666;
      margin: 0;
    }}
    .meta-row {{
      font-size: 13px;
      color: #666666;
      margin-top: 10px;
    }}
    .cost-row {{
      display: flex;
      justify-content: space-between;
      font-size: 13px;
      color: #555555;
      margin-bottom: 8px;
    }}
    .cost-row.total {{
      font-weight: 700;
      font-size: 15px;
      color: #1a1a2e;
      border-top: 1px solid #eeeeee;
      padding-top: 10px;
      margin-top: 4px;
    }}
    .due-row {{
      display: flex;
      justify-content: space-between;
      font-size: 13px;
      color: #555555;
      margin-top: 6px;
    }}
    .cta {{
      text-align: center;
      margin: 24px 0 8px 0;
    }}
    .cta-btn {{
      display: inline-block;
      background-color: #1a237e;
      color: #ffffff;
      text-decoration: none;
      padding: 13px 32px;
      border-radius: 4px;
      font-size: 14px;
      font-weight: 700;
      letter-spacing: 0.4px;
    }}
    .footer {{
      background-color: #1a237e;
      padding: 16px 28px;
      text-align: center;
    }}
    .footer p {{
      margin: 0;
      font-size: 11px;
      color: rgba(255,255,255,0.65);
    }}
  </style>
</head>
<body>
  <div class="wrapper">
    <div class="container">

      <div class="header">
        <h1>{property_name}</h1>
        <p>Booking Confirmation</p>
      </div>

      <div class="body">

        <p class="booking-ref">#{booking_ref}</p>
        <p class="confirmed-msg">
          Your booking has been confirmed. We're excited to host you.
          Wishing you a comfortable and enjoyable stay.
        </p>

        <div class="section">
          <p class="section-title">Room Details</p>
          <p style="font-size:16px; font-weight:700; color:#1a1a2e; margin:0 0 4px 0;">
            {room.get('title', 'N/A')}
          </p>
          <p style="font-size:13px; color:#777; margin:0;">
            {guest_summary}
          </p>
        </div>

        <div class="section">
          <p class="section-title">Stay Dates</p>
          <table cellpadding="0" cellspacing="0" border="0">
            <tr>
              <td>
                <div class="date-box">
                  <p class="date-label">Check In</p>
                  <p class="date-value">{format_date_day(stay.get('check_in', ''))}</p>
                  <p class="date-month">{format_date_month(stay.get('check_in', ''))}</p>
                </div>
              </td>
              <td>
                <div class="date-box">
                  <p class="date-label">Check Out</p>
                  <p class="date-value">{format_date_day(stay.get('check_out', ''))}</p>
                  <p class="date-month">{format_date_month(stay.get('check_out', ''))}</p>
                </div>
              </td>
            </tr>
          </table>
          <p class="meta-row">
            {stay.get('nights', 'N/A')} night(s) &nbsp;|&nbsp; {stay.get('rooms', 1)} room(s)
          </p>
        </div>

        <div class="section">
          <p class="section-title">Cost Summary</p>
          <div class="cost-row">
            <span>Subtotal</span>
            <span>{currency} {format_amount(pricing.get('subtotal', 0))}</span>
          </div>
          <div class="cost-row">
            <span>Taxes &amp; Surcharges</span>
            <span>{currency} {format_amount(pricing.get('total_tax_amount', 0))}</span>
          </div>
          <div class="cost-row total">
            <span>Total for stay</span>
            <span>{currency} {format_amount(pricing.get('total_amount', 0))}</span>
          </div>
          <div class="due-row">
            <span style="color:#1a237e; font-weight:600;">Due Now</span>
            <span style="color:#1a237e; font-weight:600;">
              {currency} {format_amount(pricing.get('due_now', 0))}
            </span>
          </div>
          <div class="due-row">
            <span>Due at Resort</span>
            <span>{currency} {format_amount(pricing.get('due_at_resort', 0))}</span>
          </div>
        </div>

        <div class="cta">
          <a href="{unique_url}" class="cta-btn">View Booking Details</a>
        </div>

      </div>

      <div class="footer">
        <p>This is an automated confirmation. Please do not reply to this email.</p>
        <p style="margin-top:4px;">
          Need help? Call 1-800-555-5555 &nbsp;|&nbsp; Mon–Fri 8a–5p EST
        </p>
      </div>

    </div>
  </div>
</body>
</html>
""".strip()


def build_text_email(booking):
    pricing = booking.get('pricing', {})
    stay = booking.get('stay', {})
    room = booking.get('room', {})
    currency = pricing.get('currency', '')
    booking_ref = booking.get('booking_ref', 'N/A')
    property_name = booking.get('property_name', 'Internet Booking Engine')
    unique_url = booking.get('unique_booking_url', 'N/A')
    guests = booking.get('guests', {})

    return f"""
BOOKING CONFIRMED — #{booking_ref}
{property_name}

Your booking has been confirmed. We're excited to host you.
Wishing you a comfortable and enjoyable stay.

ROOM DETAILS
Room: {room.get('title', 'N/A')}
Guests: {guests.get('summary', 'N/A')}

STAY DATES
Check In:  {stay.get('check_in', 'N/A')}
Check Out: {stay.get('check_out', 'N/A')}
Nights:    {stay.get('nights', 'N/A')}
Rooms:     {stay.get('rooms', 1)}

COST SUMMARY
Subtotal:             {currency} {format_amount(pricing.get('subtotal', 0))}
Taxes & Surcharges:   {currency} {format_amount(pricing.get('total_tax_amount', 0))}
Total for stay:       {currency} {format_amount(pricing.get('total_amount', 0))}
Due Now:              {currency} {format_amount(pricing.get('due_now', 0))}
Due at Resort:        {currency} {format_amount(pricing.get('due_at_resort', 0))}

View your booking details:
{unique_url}

---
This is an automated confirmation. Please do not reply.
Need help? Call 1-800-555-5555 | Mon-Fri 8a-5p EST
""".strip()


def format_amount(value):
    try:
        return f"{float(value):,.2f}"
    except (ValueError, TypeError):
        return '0.00'


def format_date_day(date_str):
    try:
        from datetime import datetime
        return datetime.strptime(date_str, '%Y-%m-%d').strftime('%-d')
    except Exception:
        return date_str


def format_date_month(date_str):
    try:
        from datetime import datetime
        return datetime.strptime(date_str, '%Y-%m-%d').strftime('%b %Y')
    except Exception:
        return ''
