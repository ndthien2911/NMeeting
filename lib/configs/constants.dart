import 'package:flutter/material.dart';

const DATE_FORMAT_CLIENT = 'dd/MM/yyyy';
const DATE_FORMAT_SERVER = 'yyyy-MM-dd';
const HHMM_FORMAT = 'HH:mm';
const NUMBER_GET_DATA_LIMIT = 20;
const NUMBER_GET_DATA_OFFSET = 0;
const TYPE_PAGING_WHEN_SCROLL_TOP = 0;
const TYPE_PAGING_WHEN_SCROLL_BOTTOM = 1;

const DATE_FORMAT_DATE_TYPE_1 = 'dd/MM/YYYY';
const DATE_FORMAT_TIME_TYPE_1 = 'hh:mm';

//member role
const ADMIN = 0;
const SECRETARY = 1;
const MEMBER = 2;

//status string
const STATUS_ERROR = "NG";
const STATUS_SUCCESS = "OK";

//status code
const STATUS_CODE_ERROR = 0;
const STATUS_CODE_SUCCESS = 1;

//action code
const ACTION_CREATE = 0;
const ACTION_EDIT = 1;

// calendar page
const MONTH_VTTP_BACKGROUND_COLOR = Color.fromARGB(255, 251,188,5);
const MONTH_UNITS_BACKGROUND_COLOR = Color.fromARGB(255, 58, 147, 248);
const MONTH_PERSONAL_BACKGROUND_COLOR = Color.fromARGB(255, 30, 199, 81);

// const MONTH_APPOINTMENT_MEETING_BACKGROUND_COLOR =
//     Color.fromARGB(255, 58, 147, 248);
// const MONTH_APPOINTMENT_PERSONAL_BACKGROUND_COLOR =
//     Color.fromARGB(255, 30, 199, 81);

const DAY_VTTP_BACKGROUND_COLOR = Color.fromARGB(30, 251,188,5);
const DAY_UNITS_BACKGROUND_COLOR = Color.fromARGB(255, 211, 230, 251);
const DAY_PERSONAL_BACKGROUND_COLOR = Color.fromARGB(255, 210, 241, 219);

const TYPE_MEETING_COLOR = Color.fromARGB(255, 58, 147, 248);
const TYPE_PERSONAL_COLOR = Color.fromARGB(255, 30, 199, 81);

const CALENDAR_GROUP_VTTP = 1;
const CALENDAR_GROUP_UNITS = 2;
const CALENDAR_GROUP_PERSONAL = 3;

const CALENDAR_TYPE_MEETING = 0;
const CALENDAR_TYPE_PERSONAL = 1;

//mode device
const DEVICE_480 = 0;
const DEVICE_1038 = 1;
const DEVICE_1080 = 2;
const DEVICE_NORMAL = 3;

//STATUS MEETING
const STATUS_MEETING_WAITING = 0;
const STATUS_MEETING_APPROVED = 1;
const STATUS_MEETING_REJECT = 2;

//mode
const MODE_WAITING = 0;
const MODE_APPROVED = 1;

//tab current
const TAB_WAITING = "WAITING";
const TAB_APPROVED = "APPROVED";

const PAGE_ID_FOR_APP = "mobile-app";
const PAGE_NM_FOR_APP = "Thiết bị di động";
const BTN_NAME_ADD = "AddItem";
const BTN_NAME_EDIT = "EditItem";
const BTN_NAME_DELETE = "DeleteItem";
const BTN_NAME_REJECT = "RejectItem";
const BTN_NAME_APPROVE = "ApproveBtn";
const BTN_NAME_REVERT_APPROVE = "RevertApproveBtn";
const BTN_NAME_PUBLIC = "PubicBtn";
const BTN_NAME_REVERT_PUBLIC = "RevertPublicBtn";
const BTN_ALL_TO_SAVE_CONTROL =
    '["AddItem;Tạo mới cuộc họp","EditItem;Chỉnh sửa cuộc họp","DeleteItem;Xóa cuộc họp","RejectItem;Từ chối phê duyệt cuộc họp","ApproveBtn;Duyệt cuộc họp","RevertApproveBtn;Bỏ duyệt cuộc họp","PubicBtn;Công bố cuộc họp","RevertPublicBtn;Bỏ công bố cuộc họp"]';

//type of object meeting
const TYPE_ACCOUNT = 1;
const TYPE_UNIT = 2;
const TYPE_OTHER = 3;

//index of buttom bar items
const PAGE_CALENDAR = 0;
const PAGE_PROGRESS = 1;
const PAGE_METTING = 2;
const PAGE_LIBRARY = 3;
const PAGE_NOTIFICATION = 4;
const PAGE_PROFILE = 5;

// Push notification
const PUSH_NOTIFY_APPROVE_STATUS_MEETING_TYPE = 0;
const PUSH_NOTIFY_OFFICE_TYPE = 1;
const PUSH_NOTIFY_NEWS_TYPE = 2;

// Notify meeting
const NOTIFY_INSERT_MEETING = 1;
const NOTIFY_UPDATE_MEETING = 2;
const NOTIFY_DELETE_MEETING = 3;
const NOTIFY_APPROVE_MEETING = 4;
const NOTIFY_REVERT_APPROVE_MEETING = 5;
const NOTIFY_REJECT_MEETING = 6;
const NOTIFY_MODIFY_APPROVE_MEETING = 7;
const NOTIFY_REMINDER_MEETING = 8;

// Notify office
const NOTIFY_TREATMENT_MAIN = 1;
