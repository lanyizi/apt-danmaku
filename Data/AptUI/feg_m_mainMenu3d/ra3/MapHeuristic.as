class ra3.MapHeuristic {

    public static function isBurnOutParadise(startPositions: Array): Boolean {
        var table: Array = [
            { x: 0.501199, y: 0.893535 },
            { x: 0.294496, y: 0.740820 },
            { x: 0.775716, y: 0.546769 },
            { x: 0.234452, y: 0.477302 },
            { x: 0.702504, y: 0.261562 },
            { x: 0.496599, y: 0.092047 }
        ];
        var difference: Number = 0;
        for (var i = 0; i < startPositions.length; ++i) {
            var p = startPositions[i];
            var q = table[i];
            difference += calculateDistance(p.x - q.x, p.y - q.y)
        }
        return difference < 0.01;
    }

    public static function isNormalSixPlayersMap(startPositions: Array): Boolean {
        var scores: Array = [];
        for (var i = 0; i < 6; ++i) {
            scores.push(0);
            // check valid
            var p = startPositions[i];
            if (!p || isNaN(p.x) || isNaN(p.y)) {
                return null;
            }
        }

        for (var x = 0; x < 1; x += 0.05) {
            for (var y = 0; y < 1; y += 0.05) {
                var closestDistance = null;
                var closestIndex = null;
                for (var i = 0; i < 6; ++i) {
                    var p = startPositions[i];
                    var dx = x - p.x;
                    var dy = y - p.y;
                    var distance = dx * dx + dy * dy;
                    if (closestDistance === null || distance < closestDistance) {
                        closestIndex = i;
                        closestDistance = distance;
                    }
                }
                if (closestIndex !== null) {
                    scores[closestIndex] += 1;
                }
            }
        }

        naiiveSort(scores);
        var sum0To1 = 0;
        var sum1To5 = 0;
        var sum2To5 = 0;
        for (var i = 0; i < 6; ++i) {
            if (i <= 1) {
                sum0To1 += scores[i];
            }
            if (i >= 1) {
                sum1To5 += scores[i];
            }
            if (i >= 2) {
                sum2To5 += scores[i];
            }
        }
        return ((scores[0] / sum1To5) < 0.9)
            && ((sum0To1 / sum2To5) < 1.4);
    }

    public static function judgeSixPlayersMap(startPositions: Array): String {
        var scores: Array = [];
        for (var i = 0; i < 6; ++i) {
            scores.push(0);
            // check valid
            var p = startPositions[i];
            if (!p || isNaN(p.x) || isNaN(p.y)) {
                return null;
            }
        }

        for (var x = 0; x < 1; x += 0.05) {
            for (var y = 0; y < 1; y += 0.05) {
                var closestDistance = null;
                var closestIndex = null;
                for (var i = 0; i < 6; ++i) {
                    var p = startPositions[i];
                    var dx = x - p.x;
                    var dy = y - p.y;
                    var distance = dx * dx + dy * dy;
                    if (closestDistance === null || distance < closestDistance) {
                        closestIndex = i;
                        closestDistance = distance;
                    }
                }
                if (closestIndex !== null) {
                    scores[closestIndex] += 1;
                }
            }
        }

        naiiveSort(scores);
        var sum0To1 = 0;
        var sum1To5 = 0;
        var sum2To5 = 0;
        for (var i = 0; i < 6; ++i) {
            if (i <= 1) {
                sum0To1 += scores[i];
            }
            if (i >= 1) {
                sum1To5 += scores[i];
            }
            if (i >= 2) {
                sum2To5 += scores[i];
            }
        }
        return "scores: " + scores + "; sc0/sc1to5: " + (scores[0] / sum1To5) + "; sc0to1/sc2to5: " + (sum0To1 / sum2To5);
    }

    private static function naiiveSort(array: Array) {
        var length = array.length;
        for (var i = 0; i < length; ++i) {
            var current = array[i];
            var max = current;
            var maxIndex = 0;
            for (var j = i; j < length; ++j) {
                var other = array[j];
                if (other > max) {
                    max = other;
                    maxIndex = j;
                }
            }
            if (max > current) {
                array[i] = max;
                array[maxIndex] = current;
            }
        }
    }

    private static function sort(array: Array, begin: Number, end: Number) {
		if (end - begin <= 1) {
			return;
		}
        var middle = Math.floor((begin + end) / 2);
        var pivot = array[middle];
        var backward: Number = end - 1;
        var pivotEnd: Number = end - 1;
        for (var i = begin; i < end; ++i) {
            var forwardValue = array[i];
            if (forwardValue >= pivot) {
                pivotEnd = i;
                continue;
            }
            var backwardValue = undefined;
            var j = undefined;
            for (; backward > i; --backward) {
                backwardValue = array[backward];
                if (backwardValue >= pivot) {
                    break;
                }
            }
            if (backward <= i) {
                break;
            }
            array[backward] = forwardValue;
            array[i] = backwardValue;
			pivotEnd = i;
        }
        var pivotBegin: Number = pivotEnd;
        for (var i = 0; i < pivotBegin; ++i) {
            var e = array[i];
            if (e !== pivot) {
                continue;
            }
            var backwardValue = undefined;
            for (; pivotBegin > i; --pivotBegin) {
                backwardValue = array[pivotBegin];
                if (backwardValue !== pivot) {
                    break;
                }
            }
            if (pivotBegin <= i) {
                break;
            }
            array[pivotBegin] = e;
            array[i] = backwardValue;
        }
        sort(array, begin, pivotBegin);
        sort(array, pivotEnd + 1, end);
    }

    private static function calculateDistance(x, y): Number {
        return Math.sqrt(x * x + y * y);
    }
}