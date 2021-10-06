import elke.process.Timeout;
import elke.Game;
import h2d.Object;
#if js
import io.newgrounds.NG;
import io.newgrounds.objects.Medal;
#end

class Newgrounds {
	public static var instance(get, null) : Newgrounds;

	public var isLocal = false;

	static final APP_ID = "53191:ERGdnDGm";
	static final DEFAULT_SESSION_ID = "default-session";
	static final ENCRYPTION_KEY_RC4 = "AhTBOqB08yYNIDRjFbeh4w==";

	static var _instance: Newgrounds;
	function new() {
		init();

		#if js
		new Timeout(timeoutTime, heartbeat);
		#end
	}

	var failedLogin = false;

	function init() {
		#if js
		NG.createAndCheckSession(APP_ID, DEFAULT_SESSION_ID, (e) -> {
			failedLogin = true;
		});

		NG.core.initEncryption(ENCRYPTION_KEY_RC4);

		refreshNGMedals();

		#else
		isLocal = true;
		#end
	}

	var timeoutTime = 60. * 5.;

	function heartbeat() {
		#if js
		NG.createAndCheckSession(APP_ID, DEFAULT_SESSION_ID, (e) -> {
			failedLogin = true;
		});

		NG.core.initEncryption(ENCRYPTION_KEY_RC4);

		refreshNGMedals();

		new Timeout(timeoutTime, heartbeat);
		#end
	}

	function checkSession() {
		#if js
		if (!NG.core.loggedIn) {
			NG.core.requestLogin(() -> {
				trace("Logged in");
			},
			() -> {
				trace("Pending login");
			},
			(e) -> {
				trace("Could not login");
				trace(e);
			},
			() -> {
				trace("Cancelled login");
			});
		}
		#end
	}

	function refreshNGMedals(?onComplete: Void -> Void) {
		#if js
		NG.core.requestMedals(() -> {
			if (onComplete != null) {
				onComplete();
			}
		});

		NG.core.requestScoreBoards(() -> {
			//var b = NG.core.scoreBoards.get(Const.SCOREBOARD_ID);
			//b.requestScores();
			/*
			b.onUpdate = () -> {
				for (s in b.scores) {
					trace('${s.user} : ${s.formattedValue}');
				}
			}
			*/
		});

		#end
	}

	public function unlockMedal(medalID: Int) {
		#if js
		if (NG.core.loggedIn) {
			var ngMedal = NG.core.medals.get(medalID);
			if (ngMedal == null) {
				refreshNGMedals(() -> {
					var ngMedal = NG.core.medals.get(medalID);
					if (ngMedal != null) {
						if (unlockNgMedal(ngMedal)) {
						}
					}
				});
			} else {
				if (unlockNgMedal(ngMedal)) {
				}
			}
		}
		#end
	}

	public function submitHighscore(scoreboardID: Int, totalScore: Int) {
		#if js
		if (NG.core.loggedIn) {
			var board = NG.core.scoreBoards.get(scoreboardID);
			board.postScore(totalScore);
		}
		#end
	}

	#if js
	function unlockNgMedal(m:Medal) {
		if (m.unlocked) {
			return false;
		}

		#if debug
		m.sendDebugUnlock();
		#else
		m.sendUnlock();
		#end

		return true;
	}
	#end

	public static function get_instance() {
		if (_instance == null) {
			_instance = new Newgrounds();
		}

		return _instance;
	}
}