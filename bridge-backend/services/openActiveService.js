const OPENACTIVE_URL =
    "https://openactive.io/activity-list/activity-list.jsonld";

const CACHE_DURATION = 24 * 60 * 60 * 1000; // 24 hours

let cachedData = null;
let cacheExpiresAt = 0;

/**
 * Normalize an OpenActive concept into a predictable structure.
 */
function normalizeConcept(concept) {
    return {
        id: concept.id || null,
        identifier: concept.identifier || null,
        type: concept.type || null,
        prefLabel: concept.prefLabel || null,
        notation: concept.notation || null,
        definition: concept.definition || null,
        broader: concept.broader || [],
        narrower: concept.narrower || []
    };
}

/**
 * Fetch the OpenActive activity list.
 * Cache successful responses for 24 hours.
 * Use stale cached data if a refresh fails.
 */
async function getOpenActiveData() {
    // Return cached data if it has not expired.
    if (cachedData && Date.now() < cacheExpiresAt) {
        return {
            ...cachedData,
            isStale: false
        };
    }

    try {
        const response = await fetch(OPENACTIVE_URL, {
            method: "GET",
            headers: {
                Accept: "application/ld+json, application/json"
            },
            signal: AbortSignal.timeout(10000)
        });

        if (!response.ok) {
            throw new Error(
                `OpenActive API returned HTTP ${response.status}`
            );
        }

        const data = await response.json();

        if (!Array.isArray(data.concept)) {
            throw new Error(
                "OpenActive response did not contain a valid concept list."
            );
        }

        const normalizedData = {
            title: data.title || "OpenActive Activity List",
            license: data.license || null,
            source: OPENACTIVE_URL,
            concepts: data.concept.map(normalizeConcept),
            fetchedAt: new Date().toISOString()
        };

        // Store the successful response in memory.
        cachedData = normalizedData;
        cacheExpiresAt = Date.now() + CACHE_DURATION;

        return {
            ...normalizedData,
            isStale: false
        };
    } catch (error) {
        // If we have previously fetched data, use it as a fallback.
        if (cachedData) {
            console.warn(
                "OpenActive refresh failed. Using cached data:",
                error.message
            );

            return {
                ...cachedData,
                isStale: true
            };
        }

        throw new Error(
            `Unable to retrieve OpenActive activities: ${error.message}`
        );
    }
}

/**
 * Normalize labels before comparing them.
 * This makes comparisons case-insensitive and ignores punctuation.
 */
function normalizeLabel(label) {
    return String(label)
        .toLowerCase()
        .trim()
        .replace(/[^a-z0-9]+/g, " ")
        .trim();
}

/**
 * Find an activity concept by its preferred label.
 */
async function findOpenActiveConcept(activityLabel) {
    const data = await getOpenActiveData();

    const normalizedSearch = normalizeLabel(activityLabel);

    return data.concepts.find(concept => {
        return normalizeLabel(concept.prefLabel) === normalizedSearch;
    }) || null;
}

module.exports = {
    getOpenActiveData,
    findOpenActiveConcept
};