<?php
require_once __DIR__ . '/config.php';
require_once __DIR__ . '/includes/translations.php';

// Force login
if (!isset($_SESSION['user']) || !isset($_SESSION['token'])) {
    header('Location: login.php?redirect=' . urlencode($_SERVER['REQUEST_URI']));
    exit;
}

$user = $_SESSION['user'];
$token = $_SESSION['token'];

// Get parameters
$listingType = $_GET['listing_type'] ?? null;
$listingId = (int)($_GET['listing_id'] ?? 0);
$conversationId = (int)($_GET['conversation_id'] ?? 0);

// Translations
$t = [
    'chat' => ['ar' => 'المحادثة', 'he' => 'צ\'אט', 'en' => 'Chat'],
    'conversations' => ['ar' => 'المحادثات', 'he' => 'שיחות', 'en' => 'Conversations'],
    'no_conversations' => ['ar' => 'لا توجد محادثات', 'he' => 'אין שיחות', 'en' => 'No conversations'],
    'type_message' => ['ar' => 'اكتب رسالة...', 'he' => 'כתוב הודעה...', 'en' => 'Type a message...'],
    'send' => ['ar' => 'إرسال', 'he' => 'שלח', 'en' => 'Send'],
    'you' => ['ar' => 'أنت', 'he' => 'אתה', 'en' => 'You'],
    'loading' => ['ar' => 'جاري التحميل...', 'he' => 'טוען...', 'en' => 'Loading...'],
    'error_send' => ['ar' => 'فشل إرسال الرسالة', 'he' => 'שליחת ההודעה נכשלה', 'en' => 'Failed to send message'],
    'back' => ['ar' => 'رجوع', 'he' => 'חזור', 'en' => 'Back'],
    'select_conversation' => ['ar' => 'اختر محادثة للبدء', 'he' => 'בחר שיחה להתחיל', 'en' => 'Select a conversation to start'],
    'start_chat' => ['ar' => 'بدء محادثة', 'he' => 'התחל שיחה', 'en' => 'Start Chat'],
    'chat_about' => ['ar' => 'محادثة حول', 'he' => 'שיחה על', 'en' => 'Chat about'],
];

function trc($key) {
    global $t, $lang;
    return $t[$key][$lang] ?? $t[$key]['ar'] ?? $key;
}

$pageTitle = trc('chat');

// If listing_type and listing_id provided, get or create conversation
if ($listingType && $listingId && !$conversationId) {
    $response = apiCall('chat/conversation', 'POST', [
        'listing_type' => $listingType,
        'listing_id' => $listingId
    ], $token);
    
    if ($response['success'] && isset($response['data']['id'])) {
        $conversationId = $response['data']['id'];
    }
}

// Get conversations list
$conversationsResponse = apiCall('chat/conversations', 'GET', null, $token);
$conversations = $conversationsResponse['data'] ?? [];

// Get current conversation messages
$messages = [];
$currentConversation = null;
if ($conversationId) {
    $messagesResponse = apiCall("chat/conversations/$conversationId/messages", 'GET', null, $token);
    $messages = $messagesResponse['data'] ?? [];
    
    // Find current conversation details
    foreach ($conversations as $conv) {
        if ($conv['id'] == $conversationId) {
            $currentConversation = $conv;
            break;
        }
    }
}

// Handle send message
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['message']) && $conversationId) {
    $message = trim($_POST['message']);
    if (!empty($message)) {
        $sendResponse = apiCall('chat/send', 'POST', [
            'conversation_id' => $conversationId,
            'message' => $message
        ], $token);
        
        if ($sendResponse['success']) {
            // Redirect to prevent resubmission
            header("Location: chat.php?conversation_id=$conversationId");
            exit;
        }
    }
}

require_once __DIR__ . '/includes/header.php';
?>

<style>
.chat-container {
    display: flex;
    height: calc(100vh - 120px);
    background: #f5f5f5;
}
.chat-sidebar {
    width: 320px;
    background: white;
    border-left: 1px solid #eee;
    overflow-y: auto;
}
.chat-main {
    flex: 1;
    display: flex;
    flex-direction: column;
    background: #e5ddd5;
}
.conversation-item {
    display: flex;
    align-items: center;
    padding: 12px 16px;
    border-bottom: 1px solid #f0f0f0;
    cursor: pointer;
    transition: background 0.2s;
    text-decoration: none;
    color: inherit;
}
.conversation-item:hover, .conversation-item.active {
    background: #f0f9f9;
}
.conversation-item.active {
    border-right: 3px solid var(--teal);
}
.conversation-avatar {
    width: 50px;
    height: 50px;
    border-radius: 50%;
    background: var(--teal);
    color: white;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 20px;
    margin-left: 12px;
}
.conversation-info {
    flex: 1;
    min-width: 0;
}
.conversation-name {
    font-weight: 600;
    margin-bottom: 4px;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
}
.conversation-preview {
    font-size: 13px;
    color: #666;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
}
.conversation-time {
    font-size: 11px;
    color: #999;
}
.chat-header {
    background: var(--teal);
    color: white;
    padding: 16px;
    display: flex;
    align-items: center;
    gap: 12px;
}
.chat-header-name {
    font-weight: 600;
    font-size: 16px;
}
.chat-header-listing {
    font-size: 12px;
    opacity: 0.9;
}
.chat-messages {
    flex: 1;
    overflow-y: auto;
    padding: 20px;
    display: flex;
    flex-direction: column;
    gap: 8px;
}
.message {
    max-width: 70%;
    padding: 10px 14px;
    border-radius: 12px;
    position: relative;
}
.message.sent {
    align-self: flex-start;
    background: #dcf8c6;
    border-bottom-left-radius: 4px;
}
.message.received {
    align-self: flex-end;
    background: white;
    border-bottom-right-radius: 4px;
}
.message-text {
    word-wrap: break-word;
    font-size: 14px;
    line-height: 1.5;
}
.message-time {
    font-size: 11px;
    color: #999;
    margin-top: 4px;
    text-align: left;
}
.chat-input {
    background: #f0f0f0;
    padding: 12px 16px;
    display: flex;
    gap: 10px;
}
.chat-input input {
    flex: 1;
    border: none;
    border-radius: 24px;
    padding: 12px 20px;
    font-size: 14px;
    outline: none;
}
.chat-input button {
    width: 48px;
    height: 48px;
    border-radius: 50%;
    border: none;
    background: var(--teal);
    color: white;
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 20px;
    transition: transform 0.2s;
}
.chat-input button:hover {
    transform: scale(1.05);
}
.empty-state {
    flex: 1;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    color: #666;
    background: #f9f9f9;
}
.empty-state i {
    font-size: 64px;
    color: #ccc;
    margin-bottom: 16px;
}
@media (max-width: 768px) {
    .chat-sidebar {
        width: 100%;
        display: <?= $conversationId ? 'none' : 'block' ?>;
    }
    .chat-main {
        display: <?= $conversationId ? 'flex' : 'none' ?>;
    }
}
</style>

<div class="chat-container">
    <!-- Sidebar - Conversations List -->
    <div class="chat-sidebar">
        <div class="p-3 bg-white border-bottom">
            <h5 class="mb-0"><i class="bi bi-chat-dots me-2"></i><?= trc('conversations') ?></h5>
        </div>
        
        <?php if (empty($conversations)): ?>
        <div class="text-center py-5 text-muted">
            <i class="bi bi-chat-square-text fs-1"></i>
            <p class="mt-2"><?= trc('no_conversations') ?></p>
        </div>
        <?php else: ?>
        <?php foreach ($conversations as $conv): 
            $isActive = $conv['id'] == $conversationId;
            $otherUser = $conv['other_user_name'] ?? ($lang === 'he' ? 'משתמש' : 'مستخدم');
            $lastMessage = $conv['last_message'] ?? '';
            $lastTime = isset($conv['last_message_at']) ? date('H:i', strtotime($conv['last_message_at'])) : '';
        ?>
        <a href="chat.php?conversation_id=<?= $conv['id'] ?>" class="conversation-item <?= $isActive ? 'active' : '' ?>">
            <div class="conversation-avatar">
                <?= mb_substr($otherUser, 0, 1, 'UTF-8') ?>
            </div>
            <div class="conversation-info">
                <div class="conversation-name"><?= htmlspecialchars($otherUser) ?></div>
                <div class="conversation-preview"><?= htmlspecialchars(mb_substr($lastMessage, 0, 40)) ?></div>
            </div>
            <?php if ($lastTime): ?>
            <div class="conversation-time"><?= $lastTime ?></div>
            <?php endif; ?>
        </a>
        <?php endforeach; ?>
        <?php endif; ?>
    </div>
    
    <!-- Main Chat Area -->
    <div class="chat-main">
        <?php if ($conversationId && $currentConversation): ?>
        <!-- Chat Header -->
        <div class="chat-header">
            <a href="chat.php" class="d-md-none text-white me-2"><i class="bi bi-arrow-right"></i></a>
            <div class="conversation-avatar" style="width: 40px; height: 40px; font-size: 16px; margin: 0;">
                <?= mb_substr($currentConversation['other_user_name'] ?? 'م', 0, 1, 'UTF-8') ?>
            </div>
            <div>
                <div class="chat-header-name"><?= htmlspecialchars($currentConversation['other_user_name'] ?? '') ?></div>
                <?php if (isset($currentConversation['listing_title'])): ?>
                <div class="chat-header-listing">
                    <i class="bi bi-tag me-1"></i><?= htmlspecialchars($currentConversation['listing_title']) ?>
                </div>
                <?php endif; ?>
            </div>
        </div>
        
        <!-- Messages -->
        <div class="chat-messages" id="messagesContainer">
            <?php foreach ($messages as $msg): 
                $isSent = $msg['sender_id'] == $user['id'];
            ?>
            <div class="message <?= $isSent ? 'sent' : 'received' ?>">
                <div class="message-text"><?= nl2br(htmlspecialchars($msg['message'])) ?></div>
                <div class="message-time"><?= date('H:i', strtotime($msg['created_at'])) ?></div>
            </div>
            <?php endforeach; ?>
        </div>
        
        <!-- Input -->
        <form method="POST" class="chat-input">
            <input type="text" name="message" placeholder="<?= trc('type_message') ?>" autocomplete="off" autofocus>
            <button type="submit"><i class="bi bi-send"></i></button>
        </form>
        <?php else: ?>
        <!-- Empty State -->
        <div class="empty-state">
            <i class="bi bi-chat-square-text"></i>
            <p><?= trc('select_conversation') ?></p>
        </div>
        <?php endif; ?>
    </div>
</div>

<script>
// Auto-scroll to bottom of messages
const container = document.getElementById('messagesContainer');
if (container) {
    container.scrollTop = container.scrollHeight;
}

// Auto-refresh messages every 5 seconds
<?php if ($conversationId): ?>
setInterval(() => {
    // Simple refresh - in production use AJAX for better UX
    // location.reload();
}, 30000);
<?php endif; ?>
</script>

<?php require_once __DIR__ . '/includes/footer.php'; ?>
