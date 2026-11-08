const activityCatalogue = require("../data/activityCatalogue");
const { getOpenActiveData } = require("./openActiveService");

const INTENSITY_LEVELS = {
    low: 1,
    moderate: 2,
    high: 3
};

const DEFAULT_INTENSITY = "moderate";

/**
 * Normalize labels for matching Bridge activities to OpenActive concepts.
 */
function normalizeLabel(label) {
    return String(label)
        .toLowerCase()
        .trim()
        .replace(/[^a-z0-9]+/g, " ")
        .trim();
}

/**
 * Determine the shared intensity ceiling for two users.
 *
 * The lower preference is used as a conservative starting point.
 */
function getSharedIntensityPreference(userA, userB) {
    const preferenceA = INTENSITY_LEVELS[userA.activityPreference]
        ? userA.activityPreference
        : DEFAULT_INTENSITY;

    const preferenceB = INTENSITY_LEVELS[userB.activityPreference]
        ? userB.activityPreference
        : DEFAULT_INTENSITY;

    const sharedPreference =
        INTENSITY_LEVELS[preferenceA] <= INTENSITY_LEVELS[preferenceB]
            ? preferenceA
            : preferenceB;

    return {
        userA: preferenceA,
        userB: preferenceB,
        shared: sharedPreference
    };
}

/**
 * Get physical activity recommendations shared by two users.
 */
async function getSharedActivityRecommendations(userA, userB) {
    if (!userA || !userB) {
        throw new Error("Both users are required to generate recommendations.");
    }

    const intensityPreference = getSharedIntensityPreference(userA, userB);

    const intensityCeiling =
        INTENSITY_LEVELS[intensityPreference.shared];

    // Fetch the external OpenActive dataset.
    const openActiveData = await getOpenActiveData();

    // Create a lookup for OpenActive concepts by normalized label.
    const conceptLookup = new Map();

    for (const concept of openActiveData.concepts) {
        if (concept.prefLabel) {
            conceptLookup.set(
                normalizeLabel(concept.prefLabel),
                concept
            );
        }
    }

    // Filter the curated catalogue by the shared intensity preference.
    const recommendations = activityCatalogue
        .filter(activity => {
            const activityIntensity =
                INTENSITY_LEVELS[activity.intensity];

            return activityIntensity &&
                activityIntensity <= intensityCeiling;
        })
        .map(activity => {
            const concept = conceptLookup.get(
                normalizeLabel(activity.openActiveLabel)
            );

            return {
                slug: activity.slug,
                name: activity.name,
                category: activity.category,
                intensity: activity.intensity,
                description: activity.description,

                equipment: activity.equipment || [],
                setting: activity.setting || "unspecified",

                adaptable: activity.adaptable ?? null,
                seated: activity.seated ?? null,
                wheelchairFriendly: activity.wheelchairFriendly ?? null,
                accessibilityTags: activity.accessibilityTags || [],

                source: concept ? "openactive" : "bridge-curated",

                openActive: concept
                    ? {
                        id: concept.id,
                        identifier: concept.identifier,
                        notation: concept.notation,
                        label: concept.prefLabel,
                        definition: concept.definition
                    }
                    : null
            };
        });

    return {
        count: recommendations.length,

        intensityPreference: {
            userA: intensityPreference.userA,
            userB: intensityPreference.userB,
            shared: intensityPreference.shared
        },

        recommendations,

        dataSource: {
            name: openActiveData.title,
            url: openActiveData.source,
            license: openActiveData.license,
            fetchedAt: openActiveData.fetchedAt,
            isStale: openActiveData.isStale
        },

        disclaimer:
            "Activity intensity represents a Bridge-defined participation preference, not a medical assessment or guarantee of suitability. Participants should choose activities appropriate to their individual abilities and accessibility needs."
    };
}

module.exports = {
    getSharedActivityRecommendations,
    getSharedIntensityPreference
};