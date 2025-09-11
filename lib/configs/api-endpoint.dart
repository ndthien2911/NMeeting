// const BASE_URL = 'http://localhost:8080';
// const WEBSOCKET_BASE_URL = 'ws://localhost:8080';
// const URL_WEB_CLIENT = 'http://localhost:4200/#';

// Test
// const BASE_URL = 'http://10.70.105.15:8007';
// const WEBSOCKET_BASE_URL = 'ws://10.70.105.15:8007';
// const URL_WEB_CLIENT = 'http://10.70.105.15:8006/#';

// nmeeting.html
// const BASE_URL = 'http://123.30.158.155:8011';
// const WEBSOCKET_BASE_URL = 'ws://123.30.158.155:8011';
// const URL_WEB_CLIENT = 'http://123.30.158.155/#';

// const BASE_URL = 'http://123.30.158.155:8004';
// const WEBSOCKET_BASE_URL = 'ws://123.30.158.155:8004';
// const URL_WEB_CLIENT = 'http://123.30.158.155:8005/#';

// const BASE_URL = 'http://10.70.51.34:8002';
// const WEBSOCKET_BASE_URL = 'ws://10.70.51.34:8002';
// const URL_WEB_CLIENT = 'http://10.70.51.33:8002/#';

// nmeeting.html
const BASE_URL = 'https://nmeetingapi.hcmtelecom.vn';
const WEBSOCKET_BASE_URL = 'ws://10.70.51.34:8003';
const URL_WEB_CLIENT = 'https://nmeeting.hcmtelecom.vn/#';

// dangbophuong2.html
// const BASE_URL = 'http://14.225.245.90:8002';
// const WEBSOCKET_BASE_URL = 'ws://14.225.245.90:8002';
// const URL_WEB_CLIENT = 'http://14.225.245.90:8001/#';

const URL_TOKEN = '$BASE_URL/Token';
const URL_PROPFILE = '$BASE_URL/api/Profile';
const URL_UPLOAD_AVATAR = '$BASE_URL/api/UploadAvatar/Avatar';
const URL_GET_PROPFILE = '$BASE_URL/api/User/GetProfile';
const URL_MEETING_DETAIL = '$BASE_URL/api/Meeting/GetMeetingDetail';
const URL_RESET_PASSWORD = '$BASE_URL/api/User/ResetPassword';
const URL_MEETING_DETAIL_DOCUMENT =
    '$BASE_URL/api/Meeting/DocumentMeetingDetail';
const URL_JOIN_MEETING = '$BASE_URL/api/Meeting/Join';
const URL_MEETING_END = '$BASE_URL/api/Meeting/IsMeetingEnd';
const URL_NOTIFY_COUNT_NOT_SEEN = '$BASE_URL/api/Notify/GetCntNotifyNotSeen';
const URL_SUBMIT_ABSENT = '$BASE_URL/api/Meeting/Leave';
const URL_NOTIFY_GET_ALL = '$BASE_URL/api/Notify/GetAll';
const URL_GET_ASSIGN_LIST_USER = '$BASE_URL/api/Meeting/GetAssignList';
const URL_NOTIFY_GET_USER_BY_MEETINGID =
    '$BASE_URL/api/Notify/GetUsersByMeetingIDs';
const URL_ASSIGN_USER_MEETING = '$BASE_URL/api/Meeting/AddAssignList';
const URL_MEETING_QR_CHECKED_FLG = '$BASE_URL/api/Meeting/QRCheckedFlg';
const URL_MEETING_MEMBER_HAS_CHECKIN = '$BASE_URL/api/Meeting/HasCheckIn';
const URL_MEETING_IS_INMEETING = '$BASE_URL/api/Meeting/IsInMeeting';
const WS_URL_JOIN_ABSENT = '$WEBSOCKET_BASE_URL/api/JoinAbsentWs';
const URL_GET_POLICY = '$BASE_URL/api/Policy/GetPolicy';
const URL_GET_HELP_DOCUMENT = '$BASE_URL/api/Help/GetHelpDocument';
const URL_GET_TAGS = '$BASE_URL/api/Event/GetTags';
const URL_GET_REMINDERS = '$BASE_URL/api/Event/GetReminders';
const URL_LOGOUT = '$BASE_URL/api/VNPTLogin/Logout';
const URL_LOGIN_BY_MAIL = '$BASE_URL/api/VNPTLogin/Login';
const URL_POST_CREATE_EVENT = '$BASE_URL/api/Event/AddEvent';
const URL_POST_UPDATE_EVENT = '$BASE_URL/api/Event/UpdateEvent';
const URL_GET_EVENT_DETAIL = '$BASE_URL/api/Event/GetEventDetail';
const URL_DELETE_PAGE_EVENT = '$BASE_URL/api/Event/DeletesEvent';
const URL_LOGOUT_APP = '$BASE_URL/api/Login/LogOut';

//meeting
const URL_GET_ALL_PAGE_METTING = '$BASE_URL/api/Meeting/GetAll';
const URL_CHANGE_MODE_PAGE_METTING = '$BASE_URL/api/Meeting/ChangeMode';
const URL_DELETE_PAGE_METTING = '$BASE_URL/api/Meeting/Deletes';
const URL_REJECT_PAGE_METTING = '$BASE_URL/api/Meeting/Reject';
const URL_CREATE_PAGE_METTING = '$BASE_URL/api/Meeting/AddMeeting';
const URL_UPDATE_PAGE_METTING = '$BASE_URL/api/Meeting/UpdateMeeting';
const URL_GET_ROLE_PAGE = '$BASE_URL/api/RolePage/GetRolePage';
const URL_CHECK_ROLE_PAGE = '$BASE_URL/api/RolePage/CheckRolePage';
const URL_GET_DETAIL_PAGE_METTING = '$BASE_URL/api/Meeting/GetDetailWithID';
const URL_GET_ACCOUNT_LIST = '$BASE_URL/api/User/GetUsers';
const URL_GET_USER_LIST = '$BASE_URL/api/Meeting/GetListUser';
const URL_ADDREMOVE_PERSONAL = '$BASE_URL/api/Meeting/AddOrRemovePersonal';

// websocket api
const WS_URL_CHECKIN = '$WEBSOCKET_BASE_URL/api/CheckinWs';
const WS_URL_LOGIN = '$WEBSOCKET_BASE_URL/api/LoginWebWs';
const WS_URL_NOTIFY = '$WEBSOCKET_BASE_URL/api/NotifyWs';
const WS_URL_PROGRESS = '$WEBSOCKET_BASE_URL/api/ProgressWs';
const WS_URL_VOTING_DECLARE = '$WEBSOCKET_BASE_URL/api/VotingDeclareWs';
const WS_URL_VOTING_START = '$WEBSOCKET_BASE_URL/api/VotingStartWs';
const WS_URL_VOTING_END = '$WEBSOCKET_BASE_URL/api/VotingEndWs';
const WS_URL_IDEA = '$WEBSOCKET_BASE_URL/api/IdeaWs';
const WS_URL_ADMIN_START_END_MEETING =
    '$WEBSOCKET_BASE_URL/api/StartEndMeetingWs';

// Thien
const URL_CALENDAR_BY_MONTH = '$BASE_URL/api/Calendar/GetEventByMonth';
const URL_CALENDAR_BY_DAY = '$BASE_URL/api/Calendar/GetEventByDay';
const URL_CALENDAR_BY_PERSONAL = '$BASE_URL/api/Calendar/GetEventByPersonal';
const URL_PROGRESS_GET_ALL = '$BASE_URL/api/Progress/GetAll';
const URL_VOTING_PROBLEM = '$BASE_URL/api/Voting/GetProblem';
const URL_VOTING_QUESTION_BY_PROBLEMID =
    '$BASE_URL/api/Voting/GetQuestionByProblemId';
const URL_VOTING_ANWSER_SELECTED = '$BASE_URL/api/Voting/AnwserSelected';
const URL_VOTING_COMPLETE_PROBLEM = '$BASE_URL/api/Voting/CheckCompleteProblem';
const URL_VOTING_CHECK_ALLOW = '$BASE_URL/api/Voting/CheckAllowVoting';
const URL_VOTING_CHECK_DECLARE = '$BASE_URL/api/Voting/CheckDeclareVoting';
const URL_VOTING_QUESTION_RESULT_BY_PROBLEMID =
    '$BASE_URL/api/Voting/GetQuestionResultByProblemId';
const URL_VOTING_BC_RESULT = '$BASE_URL/api/Voting/GetResultBCByProblemId';
const URL_VOTING_ADMIN_START = '$BASE_URL/api/Voting/StartVoting';
const URL_VOTING_ADMIN_END = '$BASE_URL/api/Voting/EndVoting';
const URL_IDEA_START_CHECK = '$BASE_URL/api/Idea/StartCheck';
const URL_IDEA_SEND_REGIST = '$BASE_URL/api/Idea/Regist';
const URL_IDEA_REGIST_CHECK = '$BASE_URL/api/Idea/RegistCheck';
const URL_DOCUMENT_BY_PROGRESS_ID =
    '$BASE_URL/api/Document/DocumentByProgressId';
const URL_URL_DOCUMENT_BY_ID = '$BASE_URL/api/Document/UrlDocumentById';
const URL_DOCUMENT_BY_PERSONALID =
    '$BASE_URL/api/Document/DocumentByPersonalID';
const URL_MEETING_START_END_MEETING = '$BASE_URL/api/Meeting/StartEndMeeting';
const URL_MEETING_QRSCAN = '$BASE_URL/api/Meeting/QRScan';

const URL_CHECKIN_START_END_MEETING = '$BASE_URL/api/Checkin/StartEndMeeting';
const URL_CHECKIN_MEMBER = '$BASE_URL/api/Checkin/CheckinMember';
const URL_MEETING_END_APPROVE_IDEA = '$BASE_URL/api/Meeting/EndApproveIdea';
const URL_MEETING_APPROVE_IDEA = '$BASE_URL/api/Meeting/ApproveIdea';
const URL_MEETING_READY = '$BASE_URL/api/Meeting/GetMeetingReady';
const URL_MEETING_GET_BY_TODAY = '$BASE_URL/api/Meeting/GetByToday';
const URL_APP_VERSION = '$BASE_URL/api/Config/GetAppVersion';
const URL_GET_LIST_UNIT = '$BASE_URL/api/Unit/GetForMobile';
const URL_GET_MENU_APP = '$BASE_URL/api/Page/GetMenuMb';
const URL_GET_MENU_CALENDER = '$BASE_URL/api/Calendar/GetMeetingType';
const URL_GET_UNIT_USED = '$BASE_URL/api/Config/GetUnitUsed';
