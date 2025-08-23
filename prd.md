# Rio Delivery App - Product Requirements Document (PRD)

## Executive Summary
Rio is a 15-minute medicine delivery service operating in Noida, India. This document outlines the requirements for a mobile application to manage delivery personnel (delivery boys) who are on company payroll. The app will streamline order management, cash handling, and performance tracking for efficient medicine delivery operations.

## Project Overview

### Business Context
- **Company**: Rio - 15 minute medicine delivery
- **Location**: Noida, India
- **Target Users**: Delivery boys on company payroll
- **Primary Goal**: Manage delivery operations efficiently with real-time order tracking and cash management

### Version 1 Scope
This PRD covers Version 1 of the delivery boy application focusing on core operational features. Advanced features like navigation, traffic integration, and customer signatures are planned for Version 2.

## Technology Stack

### Mobile Application
- **Framework**: Flutter (latest stable version)
- **Language**: Dart
- **State Management**: Riverpod
- **Navigation**: GoRouter
- **Local Storage**: SharedPreferences and Hive for offline data
- **QR Scanner**: mobile_scanner package
- **Image Handling**: image_picker package
- **HTTP Client**: Dio with interceptors
- **WebSocket**: web_socket_channel
- **Push Notifications**: Firebase Cloud Messaging

### Backend (Existing Infrastructure)
- **Framework**: FastAPI (Python)
- **Database**: PostgreSQL
- **Cache**: Redis
- **Real-time**: WebSockets
- **File Storage**: AWS S3 or compatible
- **Authentication**: JWT tokens

### Development Approach
- **Phase 1**: Flutter app with comprehensive mock data service
- **Phase 2**: Backend API integration
- **Testing**: Mock data allows immediate testing without backend dependency

## User Personas

### Primary User: Delivery Boy
- **Age**: 18-35 years
- **Tech Savvy**: Basic smartphone usage
- **Language**: English (Version 1)
- **Working Hours**: 8-12 hour shifts
- **Device**: Android smartphone (company provided or personal)
- **Key Needs**: Simple interface, quick actions, clear earnings visibility

## Core Features - Version 1

### 1. Authentication and Profile Management

#### Login Flow
- Phone number based authentication with country code +91 pre-filled
- OTP verification with 6-digit code input
- Auto-read OTP from SMS when possible
- Session persistence with secure token storage
- Automatic logout after 30 days of inactivity
- Device binding to prevent multiple device usage

#### Profile Management
- View and edit personal information: name, phone, emergency contact
- Upload and manage documents: Aadhaar card, PAN card, driving license
- Vehicle information: bike model, registration number
- Bank account details for salary credit
- Profile photo upload and update

### 2. Duty and Attendance Management

#### Clock In/Out System
- Start duty button with location verification
- End duty button with day summary
- Automatic location capture during clock in
- Break management: lunch break (30 min), short break (10 min)
- Break timer with notifications
- Overtime tracking beyond standard shift hours

#### Availability Status
- Three status options: Available, Busy, On Break
- Auto-switch to Busy when order accepted
- Manual override for status change
- Status visible to backend for order assignment

### 3. Order Management System

#### Order Reception
- Real-time push notifications for new orders
- Persistent notification with sound and vibration
- Order preview in notification
- Auto-assignment based on proximity and availability
- 30-second acceptance timer with auto-reject

#### Order Details View
- Customer name and masked phone number
- Complete delivery address with landmark
- Order items list with quantities
- Order value and payment method (Cash/Prepaid)
- Special instructions if any
- Pickup location code (e.g., Rack A1)
- Order timeline and SLA timer

#### Order Actions
- Accept order with single tap
- Reject order with mandatory reason selection
- Rejection reasons: Too far, Vehicle issue, Personal emergency, Already busy
- View multiple assigned orders in queue
- Priority indicators for urgent orders

### 4. QR-Based Pickup System

#### Pickup Flow
- Display pickup location code prominently
- QR scanner activation button
- Camera permission handling
- Scan location QR code for verification
- Success/failure feedback with haptic response
- List of orders at that location
- Batch pickup confirmation for multiple orders
- Option to report pickup issues

#### Pickup Verification
- Photo capture option for order package
- Timestamp recording
- Location verification
- Backend sync of pickup confirmation

### 5. Delivery Management

#### Delivery Completion
- OTP verification as primary method
- 6-digit OTP input from customer
- Fallback to manual confirmation with reason
- Photo proof of delivery (mandatory/optional based on settings)
- Photo should show package at delivery location
- Automatic timestamp and location capture

#### Cash Collection
- Display exact amount to collect
- Cash collected confirmation
- Change given amount input if applicable
- Digital receipt generation option
- Running cash balance update

### 6. Cash Management System

#### Daily Cash Flow
- Start day with opening balance declaration
- Real-time cash in hand tracking
- Order-wise cash collection log
- Maximum cash limit alerts (configurable, e.g., 10000 INR)
- Deposit prompts when limit approached

#### Reconciliation
- End of day reconciliation screen
- Total collected vs system amount
- Variance reporting if any
- Deposit confirmation with receipt number
- Historical reconciliation records

### 7. Earnings and Incentives

#### Earnings Dashboard
- Today's earnings summary card
- Base pay for the day
- Per-delivery incentive
- Special incentives (rain, late night, high demand)
- Penalties if any with reasons
- Weekly and monthly earnings graphs
- Payout date and status

#### Performance Metrics
- Total deliveries count
- On-time delivery percentage
- Average delivery time
- Customer rating (Version 2)
- Ranking among peers (optional)

### 8. Communication Features

#### Customer Communication
- One-tap call button with number masking
- Pre-defined SMS templates
- Templates: On the way, Reached location, Unable to contact
- Call log for reference

#### Support Communication
- Direct support hotline button
- In-app chat with support (Version 2)
- FAQ section for common issues
- Issue reporting with categories

### 9. Penalty Management

#### Penalty System
- Automatic penalty detection for SLA breach
- Penalty notification with amount and reason
- Appeal option with text input
- Manager approval workflow
- Penalty history view
- Impact on daily earnings

## User Interface Design Principles

### Visual Design
- Clean, minimal interface with high contrast
- Large, thumb-friendly buttons
- Clear typography with Hindi number support
- Status color coding: Green (active), Yellow (pending), Red (urgent)
- Dark mode support for night deliveries
- Battery optimization for all-day usage

### Information Architecture
- Maximum 3-tap depth for any action
- Bottom navigation for primary features
- Swipe gestures for quick actions
- Pull-to-refresh on list screens
- Persistent order notification bar

### Accessibility
- Minimum touch target size of 48x48 dp
- High contrast ratios for outdoor visibility
- Voice feedback for critical actions (optional)
- Haptic feedback for confirmations
- Large, readable fonts

## Data Models and Structure

### User Model
```
user_id (unique identifier)
phone_number (primary key)
full_name
profile_photo_url
vehicle_details (type, number)
document_urls (Aadhaar, PAN, license)
bank_account_details
emergency_contact
device_id (for binding)
created_at
updated_at
is_active
```

### Order Model
```
order_id (unique)
order_number (display)
customer_name
customer_phone (masked)
delivery_address
address_coordinates
order_items (array)
total_amount
payment_method
payment_status
pickup_location_code
assigned_to (delivery_boy_id)
status (enum)
timeline (array of status changes)
delivery_otp
delivery_proof_url
special_instructions
created_at
delivered_at
```

### Shift Model
```
shift_id
user_id
scheduled_start
scheduled_end
actual_start
actual_end
clock_in_location
clock_out_location
breaks_taken (array)
total_break_duration
status
```

### Cash Transaction Model
```
transaction_id
user_id
order_id (nullable)
transaction_type (collection, deposit, penalty)
amount
running_balance
timestamp
reconciliation_id
notes
```

### Pickup Location Model
```
location_id
location_code (A1, B2, etc.)
qr_code_data
rack_description
is_active
last_scanned_at
last_scanned_by
```

## API Specifications

### Authentication Endpoints
- `POST /api/v1/auth/send-otp` - Send OTP to phone number
- `POST /api/v1/auth/verify-otp` - Verify OTP and return JWT token
- `POST /api/v1/auth/refresh` - Refresh JWT token
- `POST /api/v1/auth/logout` - Logout and invalidate token

### User Management Endpoints
- `GET /api/v1/users/profile` - Get user profile
- `PUT /api/v1/users/profile` - Update profile information
- `POST /api/v1/users/documents` - Upload documents
- `PUT /api/v1/users/status` - Update availability status

### Shift Management Endpoints
- `POST /api/v1/shifts/clock-in` - Start shift
- `POST /api/v1/shifts/clock-out` - End shift
- `POST /api/v1/shifts/break/start` - Start break
- `POST /api/v1/shifts/break/end` - End break
- `GET /api/v1/shifts/current` - Get current shift details

### Order Management Endpoints
- `GET /api/v1/orders/pending` - Get assigned pending orders
- `GET /api/v1/orders/{order_id}` - Get specific order details
- `POST /api/v1/orders/{order_id}/accept` - Accept order
- `POST /api/v1/orders/{order_id}/reject` - Reject order with reason
- `GET /api/v1/orders/{order_id}/pickup-location` - Get pickup details
- `POST /api/v1/orders/{order_id}/pickup` - Confirm pickup
- `POST /api/v1/orders/{order_id}/deliver` - Mark as delivered
- `POST /api/v1/orders/{order_id}/collect-cash` - Confirm cash collection

### QR Verification Endpoints
- `POST /api/v1/qr/verify-location` - Verify pickup location QR
- `GET /api/v1/qr/location/{location_code}/orders` - Get orders at location

### Cash Management Endpoints
- `POST /api/v1/cash/declare-opening` - Declare opening balance
- `GET /api/v1/cash/balance` - Get current cash balance
- `POST /api/v1/cash/deposit` - Record cash deposit
- `GET /api/v1/cash/transactions` - Get cash transaction history
- `POST /api/v1/cash/reconcile` - End of day reconciliation

### Earnings Endpoints
- `GET /api/v1/earnings/today` - Get today's earnings
- `GET /api/v1/earnings/weekly` - Get weekly earnings
- `GET /api/v1/earnings/monthly` - Get monthly earnings
- `GET /api/v1/earnings/penalties` - Get penalty details

### WebSocket Events
- `new_order` - New order assigned
- `order_cancelled` - Order cancelled by customer
- `status_update` - Order status update
- `cash_limit_alert` - Cash limit approaching
- `shift_reminder` - Shift start/end reminders
- `announcement` - Broadcast messages

## Offline Functionality

### Offline Capabilities
- Cache last 50 orders locally
- Queue order status updates when offline
- Store delivery photos locally until uploaded
- Maintain cash transaction log offline
- Sync automatically when connection restored
- Show offline indicator in app header
- Preserve incomplete forms during connection loss

### Data Sync Strategy
- Timestamp all offline actions
- Priority queue for sync (deliveries first)
- Conflict resolution (server wins)
- Retry mechanism with exponential backoff
- Background sync when app minimized

## Security Requirements

### Authentication Security
- JWT tokens with 24-hour expiry
- Refresh token with 30-day validity
- Biometric authentication option
- Device binding with unique device ID
- Session invalidation on suspicious activity

### Data Security
- HTTPS only communication
- Certificate pinning for API calls
- Encrypted local storage for sensitive data
- No customer phone numbers in logs
- PII data masking in screenshots

### Operational Security
- Photo metadata stripping
- Location access only during duty
- Camera access only for required features
- Rate limiting on API calls
- Audit logs for all transactions

## Performance Requirements

### App Performance
- Cold start under 3 seconds
- Screen transition under 300ms
- API response timeout 10 seconds
- Image upload max 5MB
- Offline mode activation under 1 second
- Battery usage under 15% per shift

### Reliability
- 99.9% uptime for critical features
- Automatic crash reporting
- Graceful degradation for non-critical features
- Duplicate order prevention
- Transaction idempotency

## Testing Requirements

### Testing Phases
- Unit tests for business logic
- Widget tests for UI components
- Integration tests for API calls
- End-to-end tests for critical flows
- User acceptance testing with delivery boys
- Load testing for 1000+ concurrent users

### Test Scenarios
- Multiple order handling
- Offline to online transition
- QR scan failures
- Payment collection edge cases
- Network interruption during critical actions
- App backgrounding and restoration

## Mock Data Service Specifications

### Mock Data Requirements
- 20 sample orders with varied statuses
- 5 pickup locations with QR codes
- Delivery OTPs: Accept any 6-digit number
- Cash transactions with running balance
- Earnings data for 30 days
- Penalty examples with reasons
- Support for all order states

### Mock Service Behavior
- Simulate network delays (500-1500ms)
- Random order generation every 2 minutes
- Automatic status progression option
- Error simulation for testing
- Configurable success/failure rates
- Local data persistence

## Deployment Strategy

### Phase 1: Development (Week 1)
- Flutter app with complete mock data
- All UI screens functional
- Mock service for all features
- Internal testing with team

### Phase 2: Integration (Week 2)
- FastAPI backend development
- Replace mock services gradually
- WebSocket integration
- End-to-end testing

### Phase 3: Pilot (Week 3)
- Deploy with 10 delivery boys
- Monitor and collect feedback
- Bug fixes and improvements
- Performance optimization

### Phase 4: Rollout (Week 4)
- Full deployment to all delivery boys
- Training and documentation
- Support system setup
- Monitoring and analytics

## Success Metrics

### Operational Metrics
- Average order acceptance time under 30 seconds
- Delivery completion rate above 95%
- Cash reconciliation accuracy above 99%
- App crash rate below 0.1%
- Daily active usage above 90%

### Business Metrics
- Reduction in delivery time by 20%
- Reduction in cash discrepancies by 50%
- Improved order tracking accuracy to 100%
- Delivery boy satisfaction score above 4/5

## Future Enhancements (Version 2)

### Navigation Features
- Turn-by-turn navigation to pickup
- Route optimization for multiple orders
- Traffic integration
- Voice navigation support

### Advanced Features
- Customer signature capture
- Route recording and playback
- Hindi language support
- AI-based order clustering
- Gamification elements
- Referral system for new delivery boys

## Appendix

### Error Codes
- AUTH001 to AUTH010: Authentication errors
- ORD001 to ORD020: Order related errors
- QR001 to QR005: QR scanning errors
- CASH001 to CASH010: Cash management errors
- NET001 to NET005: Network related errors

### Status Codes
- **Order Status**: NEW, ASSIGNED, ACCEPTED, PICKUP_PENDING, PICKED_UP, IN_TRANSIT, DELIVERED, COMPLETED
- **Payment Status**: PENDING, CASH_COLLECTED, ONLINE_PAID
- **Shift Status**: NOT_STARTED, ACTIVE, ON_BREAK, ENDED
- **User Status**: AVAILABLE, BUSY, ON_BREAK, OFFLINE

### Notification Templates
- New Order: "New order from {location} - ₹{amount}"
- Cash Limit: "Cash limit reaching. Please deposit soon"
- Shift Start: "Your shift starts in 30 minutes"
- Order Timeout: "Order will timeout in 30 seconds"

### Support Contact
- Technical Support: Available 24x7
- In-app support button for immediate assistance
- FAQ section for common issues
- Video tutorials for app usage
