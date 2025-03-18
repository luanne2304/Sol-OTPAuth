# Sol-OTPAuth
AuthOTP Smart Contract

Mô tả

AuthOTP là một smart contract chạy trên Ethereum blockchain nhằm cung cấp dịch vụ xác thực OTP (One-Time Password) thông qua các nền tảng như WhatsApp và Telegram. Hệ thống bao gồm cơ chế quản lý bot xác thực, tạo và xác minh OTP, cũng như lưu trữ hash dữ liệu để đảm bảo tính toàn vẹn.

Chức năng chính

1. Quản lý Bot

addBot(string memory _phoneNumber, TypeMethod _typeMethod)
Thêm bot xác thực với số điện thoại và loại phương thức (WhatsApp hoặc Telegram).

updateBot(uint _botId, string memory _phoneNumber, TypeMethod _typeMethod, bool _status)
Cập nhật thông tin bot dựa trên ID bot.

findAvailableBot(TypeMethod _typeMethod) internal view returns (uint)
Tìm bot có sẵn theo phương thức xác thực.

2. Xác thực OTP

requestAuthentication(string memory _userPhoneNumber, string memory _publicKey, TypeMethod _typeMethod)
Tạo OTP ngẫu nhiên, gán bot để xử lý yêu cầu và lưu trữ OTP kèm theo publicKey.

validateOTP(uint256 _otp, string memory userPhoneNumber) public returns (string memory)
Kiểm tra OTP nhập vào có hợp lệ không.

3. Xác minh và lưu trữ dữ liệu băm

completeAuthentication(string memory _data, string memory _publicKey)
Kiểm tra xem publicKey có tồn tại không.
Kiểm tra xem publicKey đã có hash chưa.
Nếu hợp lệ, tạo hash mới từ dữ liệu và lưu vào publicKeyHashes.

verifyHash(string memory _publicKey, bytes32 _dataHash) public view returns (bool)
Kiểm tra dữ liệu băm có hợp lệ không trong khoảng thời gian 15 phút.

Cách hoạt động
Admin thêm bot vào hệ thống.
User gửi yêu cầu xác thực qua số điện thoại và nhận OTP.
User nhập OTP để xác thực.
Nếu hợp lệ, user có thể gửi dữ liệu để được băm và lưu trữ.
User có thể kiểm tra lại dữ liệu bằng cách xác minh hash.

Cấu trúc dữ liệu

DetailBot: Quản lý thông tin bot xác thực.
OTP: Lưu trữ OTP được tạo ra.
HashRecord: Lưu trữ dữ liệu băm.

Giới hạn và bảo mật

OTP có hiệu lực trong 5 phút (300 giây).
Hash dữ liệu có thể được xác minh trong 3 ngày (259200 giây).
Mỗi bot chỉ phục vụ một yêu cầu OTP tại một thời điểm.
